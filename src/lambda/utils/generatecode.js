const {ramdomBytes} = require('crypto');

function generateCode() {
    return ramdomBytes(3).toString('hex');
};

module.exports = {generateCode};