/* - Init - */

function init()
{
    setLanguage(getCookie("language"));
    
    // Set up animation on scroll.
    window.onscroll = function (e) {
        var rotate = document.getElementsByClassName("rotate-on-scroll");
        var rotateTransform = "rotate(" + (document.body.scrollTop / document.body.scrollHeight * 360 * 6) + "deg)";
      
        for (var i=0; i<rotate.length; ++i) rotate[i].style.webkitTransform = rotateTransform;
    };
}

/* - Navigator - */

function toggleExpanded(element)
{
	if (!hasClass(element, 'expanded')) {
	    addClass(element, 'expanded');
		
		// Close non-ancestor sections/subsections.
		var classNames = ["nav-section", "nav-subsection"];
		for (var i=0; i<classNames.length; ++i) {
		    var navSections = document.getElementsByClassName(classNames[i]);
		    
    		for (var j=0; j<navSections.length; ++j) {
                var navSection = navSections[j];
                
                if (!isAncestorOrSelf(element, navSection)) {
                    removeClass(navSection, 'expanded');
                }
            }
        }
	} else {
		removeClass(element, 'expanded');
	}
}

/* - Language Striping - */

function setLanguage(language)
{
    setCookie("language", language, 60);
    
    var stripes = document.getElementsByClassName("language-stripe");
    var activeStripe = null;
    
    // Turn on the selected stripe and turn the others off.
    for (var i=0; i<stripes.length; ++i) {
        var stripe = stripes[i];
        
        if (stripe.id == "language-stripe-" + language) {
            stripe.disabled = false;
            activeStripe = stripe;
        } else {
            stripe.disabled = true;
        }
    }
    
    // If we didn't find a stripe then show the 1st one as default.
    if (stripes.length > 0 && activeStripe == null) {
        activeStripe = stripes[0];
        activeStripe.disabled = false;
    }
    
    // Set language selection element.
    if (activeStripe != null) {
        var languageSelect = document.getElementById("language-select");
        
        if (languageSelect != null) {
            languageSelect.value = language;
        }
    }
}

/* - Cookies - */

function setCookie(name, value, daysValid)
{
    var expires = new Date();
    expires.setTime(expires.getTime() + (daysValid * 24 * 60 * 60 * 1000));
    
    document.cookie = name + "=" + value + "; expires=" + expires.toGMTString() + ";path=/";
}

function getCookie(name)
{
    var cookies = document.cookie.split(';');
    var value = null;
    
    for(var i=0; i<cookies.length; i++) 
    {
        var cookie = cookies[i].trim();
        
        if (cookie.indexOf(name + "=")==0) {
            value = cookie.substring(name.length + 1, cookie.length);
            if (value.length == 0) value = null;
        }
    }
    
    return value;
}

/* - Util - */

function hasClass(element, className)
{
    return ((' ' + element.className + ' ').indexOf(' ' + className + ' ') > -1);
}

function addClass(element, className)
{
    if (element.className.indexOf(className) == -1) {
        element.className += ' ' + className;
    }
}

function removeClass(element, className)
{
    element.className = (' ' + element.className + ' ').replace(' ' + className + ' ', '').trim();
}

function isAncestorOrSelf(element, otherElement)
{
    while (element != null) {
        if (element == otherElement) return true;
        element = element.parentNode;
    }
    
    return false;
}

function size(object) {
    var size = 0;
    
    for (key in object) {
        size++;
    }
    
    return size;
}

function getQueryParameter(name) {
    var match = RegExp('[?&]' + name + '=([^&]*)').exec(window.location.search);
    return match && decodeURIComponent(match[1].replace(/\+/g, ' '));
}