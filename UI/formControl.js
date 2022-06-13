
function closeForm(){
    // remove the form from DOM
    const currentForm = this.parentElement.parentElement.parentElement;
    currentForm.className = "form-background close";
}

function openForm(){
    // remove the button from DOM
    let currentForm = 
        this.classList.contains("delete") ? document.querySelector(".form2") : document.querySelector(".form1");


    // display form
    let formBackground = currentForm.parentElement.parentElement;
    formBackground.className = ("form-background open");
    // reset form input default state
    currentForm.querySelectorAll(".form-control").forEach(control => control.className = "form-control");
}

function checkInput(){
    // reset form input default state
    const form1 = document.querySelector(".form1");
    form1.querySelectorAll(".form-control").forEach(control => control.className = "form-control");

    // get input element
    const productID = form1.querySelector("#ID");
    const productName = form1.querySelector("#product-name");
    const smallCheck = form1.querySelector("#small-size");
    const smallPrice = form1.querySelector("#small-price");
    const largeCheck = form1.querySelector("#large-size");
    const largePrice = form1.querySelector("#large-price");
    // check input value
    const productIDValue = productID.value.trim();
    const productNameValue = productName.value.trim();
    const smallPriceValue = smallPrice.value.trim();
    const largePriceValue = largePrice.value.trim();
   
    console.log(productIDValue, productNameValue);

    let validInput = false;
    let validID = false, validName = false, validPrice = false;

    if(productIDValue === "") {
        setErrorFor(productID, "ID cannot be blank!");
    } 
    else if(isNaN(productIDValue)) {
        setErrorFor(productID, "ID must be a numeric value!");
    }
    else {
        setSuccessFor(productID);
        validID = true;
    }

    if(productNameValue === "") {
        setErrorFor(productName, "Product's name must be fulfilled!");
    }
    else{
        setSuccessFor(productName);
        validName = true;
    }

    if(!smallCheck.checked && !largeCheck.checked) {
        setErrorFor(smallCheck, "At least one size must be checked");
        setErrorFor(largeCheck, "At least one size must be checked");
    } 
    else {
        if(smallCheck.checked) {
            if(!smallPriceValue) setErrorFor(smallPrice, "Price cannot be blank");
            else if(isNaN(smallPriceValue)) setErrorFor(smallPrice, "Price must be a numeric value");
            else {
                setSuccessFor(smallPrice);
                validPrice = true;
            }
        }        
        if(largeCheck.checked) {
            if(!largePriceValue) setErrorFor(largePrice, "Price cannot be blank");
            else if(isNaN(largePriceValue)) setErrorFor(largePrice, "Price must be a numeric value");
            else {
                setSuccessFor(largePrice);
                validPrice = true;
            }
        }
    }
    validInput = validID && validName && validPrice;
    if(validInput) form1.submit();

}

function setSuccessFor(target) {
    const formControl = target.parentElement;
    formControl.className = ('form-control success');
}

function setErrorFor(target, errorMsg) {
    const formControl = target.parentElement;
    const errorSmall = formControl.querySelector("small");
    formControl.className = ('form-control error');
    errorSmall.innerText = errorMsg;
}


document.querySelector(".form1").addEventListener('submit', e => {
    e.preventDefault();
    checkInput();
});

document.querySelector(".form2").addEventListener('submit', e => {
    e.preventDefault();
    const deleteForm = document.querySelector(".form2");
    deleteForm.submit();
});

document.querySelectorAll(".form-close").forEach(closeBtn => closeBtn.addEventListener('click', closeForm));

document.querySelector("header").addEventListener('click', function(e) {
    if(e.target.classList.contains("form-open")) openForm.call(e.target);
})

document.querySelector(".table-container").addEventListener('click', function(e) {
    if(e.target.classList.contains("form-open")) openForm.call(e.target);
})
