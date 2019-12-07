const Zlib = require('zlib');
const axios = require('axios')

const lambdaVersion = function (logStream) {
    let start = logStream.indexOf('[');
    let end = logStream.indexOf(']');
    return logStream.substring(start+1, end);
}

exports.handler = async (event, context) => {

  event.Records.forEach(record => {
    const payload = new Buffer(record.kinesis.data, 'base64');
    const json    = (Zlib.gunzipSync(payload)).toString('utf8');
    const data    = JSON.parse(json);

    const functionName    = data.logGroup.split('/').reverse()[0];
    const functionVersion = lambdaVersion(data.logStream);
    const awsRegion       = record.awsRegion;

    const ip      = process.env.INFLUXDB_IP
    const org     = process.env.INFLUXDB_ORG
    const bucket  = process.env.INFLUXDB_BUCKET
    const token   = process.env.INFLUXDB_TOKEN

    data.logEvents.forEach((event) => {
   
      if (event.message.startsWith('REPORT RequestId')){
           
        const headers = {
          'Content-Type': 'text/plain',
          'Authorization': `Token ${token}`
        }

        var url   = `http://${ip}:9999/api/v2/write?org=${org}&bucket=${bucket}&precision=ns`

        var used      = event.extractedFields.max_memory_used_value
        var usage     = event.extractedFields.memory_size_value
        var duration  = event.extractedFields.billed_duration_value

        var data  = `function,name=${functionName},version=${functionVersion},region=${awsRegion} `+
                    `duration=${duration},used=${used},usage=${usage}`
        
        axios.post(url, data, {
          headers: headers
        })
        .then((response) => {
          console.log(response.status)
        })
        .catch((error) => {
          console.log(error)
        })
          
      }
    })
  })
  return 'done';
}