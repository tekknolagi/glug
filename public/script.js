$(window).load(function() {
    if ($('#new')) $('#new').focus();
    
    var urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
    $(".comments li").each(function(elNum) {
	$(this).html($(this).html().replace(urlRegEx, "<a href='$1' target='_blank'>$1</a>"));
    });
});
