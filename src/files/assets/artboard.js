function $$(id) {
  return document.getElementById(id);
}

function addClass(el, classname) {
  el.classList.add(classname);
}

function removeClass(el, classname) {
  el.classList.remove(classname);
}

function enterWindow(window) {
  var $nav = $$('artboard-nav');
  var addAutohideClassToNav = addClass.bind(null, $nav, 'js-autohide');
  var removeAutohideClassFromNav = removeClass.bind(null, $nav, 'js-autohide');

  var autohideTimeout;
  window.addEventListener('mousemove', function (event) {
    removeAutohideClassFromNav();
    clearTimeout(autohideTimeout);
    autohideTimeout = setTimeout(addAutohideClassToNav, 1000);
  });
}

enterWindow(window);