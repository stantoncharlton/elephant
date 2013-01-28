
(function ($) {

    $("ul").live("active", function() {
        alert("hello");
        if( $(this).has("a.ui-state-hover") ) {
            $(this).addClass("autocomplete-hover");
        }
    });

}(jQuery));