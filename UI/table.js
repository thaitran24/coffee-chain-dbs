
function sortTableByColumn(table, index, asc = true) {
    const dirModifier = asc ? 1 : -1;
    const tBody = table.tBodies[0];
    const rows = Array.from(tBody.querySelectorAll("tr"));

    const sortedRows = rows.sort((a, b) => {
        const aColText = a.querySelector(`td:nth-child(${index + 1})`).textContent.trim();
        const bColText = b.querySelector(`td:nth-child(${index + 1})`).textContent.trim();

        return aColText > bColText ? (1 * dirModifier) : (-1*dirModifier);
    });

    //remove all old rows
    while (tBody.firstChild) {
        tBody.removeChild(tBody.firstChild);
    }
    //append sorted rows to the table's body
    tBody.append(...sortedRows);

    table.querySelectorAll("th").forEach(th => th.classList.remove("th-sort-asc", "th-sort-desc"));
    // add ID th-sort-asc if asc option is true, otherwise add ID th-sort-desc
    table.querySelector(`th:nth-child(${index + 1}`).classList.toggle("th-sort-asc", asc);
    table.querySelector(`th:nth-child(${index + 1}`).classList.toggle("th-sort-desc", !asc);

}


function selectRow() {
    const selected = this.parentElement.classList.contains("selected");
    const body = this.parentElement.parentElement;

    body.querySelectorAll("tr").forEach(row => row.classList.remove("selected"))
 
    if(!selected) {
        this.parentElement.classList.add("selected");
    }
} 

/*
 function addTableSortEvent() {


    rows.forEach(row => {
        row.addEventListener("click", selectRow);
    });

    document.querySelectorAll(".content-table th").forEach(headerCell => {
        headerCell.addEventListener("click", () => {
            const headerIndex = Array.prototype.indexOf.call(headerCell.parentElement.children, headerCell);
            const currentIsAscending = headerCell.classList.contains("th-sort-asc");

            const tableElement = headerCell.parentElement.parentElement.parentElement;
            sortTableByColumn(tableElement, headerIndex, !currentIsAscending);
        });
    });
}
*/

function sortRow() {
    const headerIndex = Array.prototype.indexOf.call(this.parentElement.children, this);
    const currentIsAscending = this.classList.contains("th-sort-asc");

    const tableElement = this.parentElement.parentElement.parentElement;
    sortTableByColumn(tableElement, headerIndex, !currentIsAscending);
}

function getDeleteID(){
    const IdValue = this.parentElement.parentElement.cells[0].innerText;
    const deleteIdInput = document.querySelector(".form2 input");
    deleteIdInput.value = IdValue;

}

document.querySelector(".table-container").addEventListener('click', function(e) {
    if(e.target.classList.contains("delete")) getDeleteID.call(e.target);
})

document.querySelector(".table-container").addEventListener('click', function(e) {
    if(e.target.tagName === "TH") sortRow.call(e.target);
})

document.querySelector(".table-container").addEventListener('click', function(e) {
    if(e.target.tagName === "TD") selectRow.call(e.target);
})

/*
selectRow.call(document.querySelector(".content-table tr"));
console.log(document.querySelector(".content-table tr"));

//addTableSortEvent();*/
