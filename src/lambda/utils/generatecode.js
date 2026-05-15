const { randomBytes } = require('crypto');

function generateCode() {
    return randomBytes(3).toString('hex');
}

module.exports = { generateCode };