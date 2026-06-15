function clearAllData() {
  const target = document.getElementById("scriptarea");
  if (target) {
    target.innerHTML = "";
    target.style.display = "";
  } else {
    console.log("No target found");
  }
}

function displayScriptDiv(source) {
  const target = document.getElementById("scriptarea");

  if (target) {
    var srcEl = document.querySelector(source);
    var s = srcEl ? srcEl.innerHTML : "";
    target.innerHTML = s;
    target.style.display = "";
  } else {
    console.log("No target found");
  }
}
