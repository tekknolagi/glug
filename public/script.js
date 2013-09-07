

$(window).load(function() {
    var urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;

    function arrayContains(needle, arrhaystack) {
	return (arrhaystack.indexOf(needle) > -1);
    }

    function imgify(url) {
	return "<a href='"+url+"' target='_blank'><img src='"+url+"' height='150px' /></a>";
    }

    function linkify(html) {
	return html.replace(urlRegEx, "<a href='$1' target='_blank'>$1</a>");
    }
    
    if ($('#new')) $('#new').focus();
    
    $(".comments li .content").each(function(elNum) {
	var html = $(this).html();
	var matches = html.match(urlRegEx);
	if (matches != null) {
	    for (var i = 0; i < matches.length; i++) {
		var url = matches[i];
		var ext = url.split('.').pop().trim();
		var allowed = ["jpg", "jpeg", "png", "gif"];
		if (arrayContains(ext, allowed)) {
		    $(this).html(linkify(html)+"<br />"+imgify(url));
		}
		else {
		    $(this).html(linkify(html));
		}	    
	    }
	}
    });
});
