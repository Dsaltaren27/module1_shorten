const { PutCommand } = require("@aws-sdk/lib-dynamodb");
const { docClient } = require("../utils/dynamodb");
const { generateCode } = require("../utils/generateCode");

exports.handler = async (event) => {
  try {
    // Extraer datos (maneja si el body viene como string o objeto)
    const body = typeof event.body === "string" ? JSON.parse(event.body) : event.body;
    const { longUrl } = body;

    if (!longUrl) {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
        body: JSON.stringify({ error: "Falta longUrl" }),
      };
    }

    // Validar que sea una URL válida antes de guardar
    try {
      new URL(longUrl);
    } catch {
      return {
        statusCode: 400,
        headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
        body: JSON.stringify({ error: "El valor de longUrl no es una URL válida" }),
      };
    }

    // Generar código único
    const shortCode = generateCode();

    // Guardar en DynamoDB
    await docClient.send(new PutCommand({
      TableName: process.env.TABLE_NAME,
      Item: {
        shortCode: shortCode,
        longUrl: longUrl,
        createdAt: new Date().toISOString(),
        clicks: 0,
      },
    }));

    // Respuesta exitosa
    return {
      statusCode: 201,
      headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
      },
      body: JSON.stringify({ shortCode }),
    };

  } catch (error) {
    console.error("Error en shorten:", error);
    return {
      statusCode: 500,
      headers: { "Content-Type": "application/json", "Access-Control-Allow-Origin": "*" },
      body: JSON.stringify({ error: "Error interno", detail: error.message }),
    };
  }
};
