
const tracer = require("@lumigo/tracer")({
	token:'t_7afe5952d7644bd48a2f5'
});
const handler = require('../functions/io-intense').handler;

module.exports.handler = tracer.trace(handler);