$(window).load(function() {
    if ($('#new')) $('#new').focus();
    $(function() {
	var urlRegEx = /((([A-Za-z]{3,9}:(?:\/\/)?)(?:[\-;:&=\+\$,\w]+@)?[A-Za-z0-9\.\-]+|(?:www\.|[\-;:&=\+\$,\w]+@)[A-Za-z0-9\.\-]+)((?:\/[\+~%\/\.\w\-]*)?\??(?:[\-\+=&;%@\.\w]*)#?(?:[\.\!\/\\\w]*))?)/g;
	$('#target').html($('#source').html().replace(urlRegEx, "<a href='$1'>$1</a>"));
    });  
});
