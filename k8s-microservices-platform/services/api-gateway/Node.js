
const express = require('express');
const axios = require('axios');
const app = express();

app.use(express.json());

app.get('/orders', async (req, res) => {
    try {
        const response = await axios.get('http://order-service:3000/orders');
        res.json(response.data);
    } catch (err) {
        res.status(500).send("Service unavailable");
    }
});

app.listen(3000, () => console.log("API Gateway running"));
