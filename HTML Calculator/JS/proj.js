const calc = {
    displayVal: '0',
    firstVal: null,
    secondVal: false,
    operator: null,
};

function updateDisplay(){
    const display = document.querySelector('.calc-input');
    display.value = calc.displayVal;
}
updateDisplay();

function inputNum(digit){
    const {displayVal, secondVal} = calc;
    if (secondVal === true){
        calc.displayVal = digit;
        calc.secondVal = false;
    }
    else{
        calc.displayVal = displayVal === '0' ? digit : displayVal + digit;  //if displayVal is 0, output digit, otherwise digit is added to end of displayVal string
    }
}

function inputDec(dec){
    if (calc.secondVal === true){
        calc.displayVal = '0.';
        calc.secondVal = false;
        return;
    }
    if (!calc.displayVal.includes(dec)){
        calc.displayVal += dec;
    }
}

function calculate(firstVal, secondVal, operator){
    if (operator === '/'){
        return firstVal / secondVal;
    }
    else if (operator === '*'){
        return firstVal * secondVal;
    }
    else if (operator === '-'){
        return firstVal - secondVal;
    }
    else if (operator === '+'){
        return firstVal + secondVal;
    }
    return secondVal;
}

function resetCalc(){
    calc.displayVal = '0';
    calc.firstVal = null;
    calc.secondVal = false;
    calc.operator = null;
}

function Operations(nextOperation) {
    const {firstVal, displayVal, operator} = calc
    const inputVal = parseFloat(displayVal);
    if (operator && calc.secondVal){
        calc.operator = nextOperation;
        return;
    }
    if (firstVal == null && !isNaN(inputVal)){
        calc.firstVal = inputVal;
    }
    else if (operator){
        const result = calculate(firstVal, inputVal, operator);
        calc.displayVal = `${parseFloat(result.toFixed(9))}`;
        calc.firstVal = result;
    }
    calc.secondVal = true;
    calc.operator = nextOperation;
}

const calcKeys = document.querySelector('.calc-buttons');
calcKeys.addEventListener('click', (action) => {
    const target = action.target;
    const val = target.val;
    if (!target.matches('button')){return;}
    if (target.classList.contains('operator')){
        Operations(target.value);
        updateDisplay();
        return;
    }
    if (target.classList.contains('decimal')){
        inputDec(target.value);
        updateDisplay();
        return;
    }
    if (target.classList.contains('clear-everything')){
        resetCalc();
        updateDisplay();
        return;
    }
    inputNum(target.value);
    updateDisplay();
});
