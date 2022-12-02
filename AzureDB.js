const fs = require('fs');

const dotenv = require('dotenv');
dotenv.config();

const { ManagedIdentityCredential, DefaultAzureCredential } = require("@azure/identity")
const { SecretClient } = require("@azure/keyvault-secrets");

const serverCA = [fs.readFileSync("cert/DigiCertGlobalRootCA.crt.pem", "utf8")];

async function getSecretInDevEnv() {
    const tenant_id = process.env.AZURE_TENANT_ID;
    const client_id = process.env.AZURE_CLIENT_ID;
    const client_secret = process.env.AZURE_CLIENT_SECRET;
    const credential = new DefaultAzureCredential(tenant_id, client_id, client_secret);
    const keyVaultUrl = process.env.KEY_VAULT_URL;

    const keyVaultClient = new SecretClient(keyVaultUrl, credential);
    const secretName = "RehappMySQLDatabaseSecret";
    const secret = await keyVaultClient.getSecret(secretName);
    return secret;
}

async function getSecretInProdEnv() {
    const MANAGED_IDENTITY_UA_CLIENT_ID = process.env.MANAGED_IDENTITY_UA_CLIENT_ID;
    const credential = new ManagedIdentityCredential(MANAGED_IDENTITY_UA_CLIENT_ID);
    const keyVaultUrl = process.env.KEY_VAULT_URL;

    const keyVaultClient = new SecretClient(keyVaultUrl, credential);
    const secretName = "RehappMySQLDatabaseSecret";
    const secret = await keyVaultClient.getSecret(secretName);
    return secret;
}

async function getAzureDatabaseSecret() {
    const env = process.env.NODE_ENV;
    if (env == 'development') {
        return getSecretInDevEnv();
    }
    else if (env == "production") {
        return getSecretInProdEnv();
    }   
}

exports.getAzureDatabaseSecret = getAzureDatabaseSecret;

const config = {
    host: process.env.AZURE_MYSQL_HOST, 
    user: "rehappadmin", 
    password: null,
    database: "Rehapp", 
    port: 3306, 
    ssl: {
        rejectUnauthorized: true,
        ca: serverCA
    }
};

exports.config = config;