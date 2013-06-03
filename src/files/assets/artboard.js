function $$(id) {
  return document.getElementById(id);
}

function getFirstOfTagName(name) {
  return document.getElementsByTagName(name)[0];
}

function addClass(el, classname) {
  el.classList.add(classname);
}

function removeClass(el, classname) {
  el.classList.remove(classname);
}

function enterWindow(window) {
  var $html = getFirstOfTagName('html');
  var $nav = $$('artboard-nav');

  removeClass($html, 'no-js');
  addClass($html, 'js');

  var addLoadedClassToHtml = addClass.bind(null, $html, 'js-loaded');
  var addAutohideClassToNav = addClass.bind(null, $nav, 'js-autohide');
  var removeAutohideClassFromNav = removeClass.bind(null, $nav, 'js-autohide');

  var autohideTimeout;
  window.addEventListener('mousemove', function (event) {
    removeAutohideClassFromNav();
    clearTimeout(autohideTimeout);
    autohideTimeout = setTimeout(addAutohideClassToNav, 1000);
  });

  window.addEventListener('load', addLoadedClassToHtml);
}

enterWindow(window);