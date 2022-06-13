const express = require('express');
const path = require('path');

const db = require('mysql').createConnection({
    host: "localhost",
    user: "root",
    password: "password",
    database: "coffee_chain_db"
})

db.connect((err) => {
    if(err) {
        console.log("err: ", err);
    }
    else{
        console.log("Connected");
    }

})

const app = express()

app.use(express.static('./UI'))
app.use(express.urlencoded({ extended: false }))


app.get('/', (req, res) => {
    res.sendFile(path.resolve(__dirname, './UI/productTable.html'))
})



app.get('/getProducts', (req, res) => {
    let sql = "SELECT * FROM (PRODUCT P JOIN PR_PRICE C ON P.pr_id = C.pr_id);"
    db.query(sql, (err, result) => {
        if(err) console.log("error 123");
        res.json(result);
    })
})

app.post('/addProduct', (req, res) => {
    console.log(req.data);

    const {pr_id: prId, pr_name: prName, small_price: smallPrice, large_price: largePrice} = req.body;

    let sql = `INSERT INTO PRODUCT 
    VALUES(${prId}, '${prName}');`
    db.query(sql, (err, result) => {
        if(err) console.log("error", err.sqlMessage);
    }) 
    if(smallPrice) {       
        let sql2 = 
            `INSERT INTO PR_PRICE 
            VALUES(${prId}, 'S', '${smallPrice}');`
        db.query(sql2, (err, result) => {
            if(err) console.log("error", err.sqlMessage);
        })    
    }
    if(largePrice) {     
        let sql2 = 
            `INSERT INTO PR_PRICE 
            VALUES(${prId}, 'L', '${largePrice}');`
        db.query(sql2, (err, result) => {
            if(err) console.log("error", err.sqlMessage);
        })    
    }
    res.redirect(301, '/');
})

app.post('/updateProduct', (req, res) => {
    res.send("POST");
})

app.post('/deleteProduct', (req, res) => {
    const deleteId = req.body;
    let sql1 = `DELETE FROM PRODUCT WHERE pr_id = '${deleteId}'`;
    db.query(sql1, (err, result) => {
        if(err) console.log("error", err.sqlMessage);
    })   
    let sql2 = `DELETE FROM PR_PRICE WHERE pr_id = '${deleteId}'`;
    db.query(sql2, (err, result) => {
        if(err) console.log("error", err.sqlMessage);
    })   
    res.redirect(301, '/');
})

app.listen(3000, () => {
    console.log("server listening on port 3000")
})
