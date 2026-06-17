function clearAllData() {
  const target = document.getElementById("scriptarea");
  if (target) {
    target.innerHTML = "";
  } else {
    console.log("No target found");
  }
}

function displayScript(script) {
  const target = document.getElementById("scriptarea");

  if (target) {
    target.innerHTML = "<div>" + script + "</div>";
  } else {
    console.log("No target found");
  }
}
