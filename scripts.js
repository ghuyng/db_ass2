const { request, response } = require('express')

exports.login = (request, response) => {
  console.log("login!!")
  response.render('pages/login', {})
}

// function login(request, response) {
//   console.log("login!!")
//   response.render('pages/login', {})
// }

// module.exports = {
//   login
// }

