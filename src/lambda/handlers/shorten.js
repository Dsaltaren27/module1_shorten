const { PutCommand } = require("@aws-sdk/lib-dynamodb");
const { docClient } = require("../utils/dynamodb");
const { generateCode } = require("../utils/generateCode");

exports.handler = async (event) => {
  try {
    // Extraer datos (maneja si el body viene como string o objeto)
    const body = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    const { longUrl } = body;

    if (!longUrl) {
      return { statusCode: 400, body: JSON.stringify({ error: "Falta longUrl" }) };
    }

    // Generar código único
    const shortCode = generateCode();

    // Guardar en DynamoDB de forma ASÍNCRONA
    const params = {
      TableName: process.env.TABLE_NAME,
      Item: {
        shortCode: shortCode,
        longUrl: longUrl,
        createdAt: new Date().toISOString(),
        clicks: 0
      },
    };

    await docClient.send(new PutCommand(params));

    // Respuesta exitosa con CORS habilitado
    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*"
      },
      body: JSON.stringify({
        shortCode,
        shortUrl: `https://${event.requestContext.domainName || 'api.local'}/${shortCode}`
      }),
    };
  } catch (error) {
    console.error(error);
    return { 
      statusCode: 500, 
      body: JSON.stringify({ error: "Error interno", detail: error.message }) 
    };
  }
};