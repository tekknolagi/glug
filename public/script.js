$(window).load(function() {
    function arrayContains(needle, arrhaystack) {
	return (arrhaystack.indexOf(needle) > -1);
    }
    
    if ($('#new')) $('#new').focus();
    
    var urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
    $(".comments li").each(function(elNum) {
	var html = $(this).html();
	if (html.match(urlRegEx)) {
	    var ext = html.split('.').pop().trim();
	    var allowed = ["jpg", "jpeg", "png", "gif"];
	    if (arrayContains(ext, allowed)) {
		$(this).html(html.replace(urlRegEx, "<img src='$1' height='150px' />"));
	    }
	    else {
		$(this).html(html.replace(urlRegEx, "<a href='$1' target='_blank'>$1</a>"));	
	    }
	}
    });
});
