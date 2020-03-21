const https = require('https')

module.exports.handler = (event, context, callback) => {
  const { url } = JSON.parse(event.body)
  https.get(url, (res) => {
    console.log('statusCode:', res.statusCode)
    callback(null, {
      statusCode: 200,
      body: "{}"
    })
  }).on('error', (e) => {
    console.error(e)
  })
}