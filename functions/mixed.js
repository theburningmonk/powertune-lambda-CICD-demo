const https = require('https')

exports.handler = ({ n }, context, callback) => {
  https.get('https://google.com', (res) => {
    console.log('statusCode:', res.statusCode)
    
    let a = 1, b = 0, temp
    while (n > 0) {
      temp = a
      a = a + b
      b = temp
      n--
    }

    callback(null, b)
  }).on('error', (e) => {
    console.error(e)
  })
}