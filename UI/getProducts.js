async function getProducts() {
    const response = await axios.get('/getProducts');
    displayProduct(response.data);
    /*
    .then(res => {
        displayProduct(res.data);
    })
    .catch(err => console.log(err))
    */
}
function displayProduct(products) {
    let tableHead = `
    <thead>
        <tr>
            <th>Product ID</th>
            <th>Product Name</th>
            <th>Size</th>
            <th>Price</th>
        </tr>
    </thead>`

    let tableBody = `<tbody>`
    products.forEach(product => {
        const{pr_id, pr_name, size, price} = product;
        let row = `
        <tr>
            <td> ${pr_id}</td>
            <td> ${pr_name}</td>
            <td> ${size}</td>
            <td> ${price}</td>
            <td>
                <button class="form-open update">
                    Update
                </button>
            </td>
            <td>
                <button class="form-open delete">
                    Delete
                </button>
            </td>
        </tr>`;
        tableBody += row; 
    });
    tableBody += `</tbody>`;

    const productTable = '<table class="content-table">' + tableHead + tableBody + '</table>'
    const tableContainer = document.querySelector(".table-container");
    tableContainer.innerHTML = productTable;
}

axios.get('/getProducts')
.then(res => {
    displayProduct(res.data);
})
.catch(err => console.log(err))
