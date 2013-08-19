$(function() {
    $("#users th a, #users .pagination a").live("click", function() {
        $.getScript(this.href);
        return false;
    });
    $("#users_search input").keyup(function() {
        $.get($("#users_search").attr("action"), $("#users_search").serialize(), null, "script");
        return false;
    });

    $("#inline_search input").keyup(function() {
        if($('#search_results').length > 0) {
            $('#search_results').addClass('hidden');
            $('#search_loading').removeClass('hidden');
            $('#search_loading').find('.loading').removeClass('hidden');
        }
        $.get($("#inline_search").attr("action"), $("#inline_search").serialize(), null, "script");
        return false;
    });

    $("#clients th a, #clients .pagination a").live("click", function() {
        $.getScript(this.href);
        return false;
    });
    $("#clients_search input").keyup(function() {
        $.get($("#clients_search").attr("action"), $("#clients_search").serialize(), null, "script");
        return false;
    });

    $("#districts th a, #districts .pagination a").live("click", function() {
        $.getScript(this.href);
        return false;
    });
    $("#districts_search input").keyup(function() {
        $.get($("#districts_search").attr("action"), $("#districts_search").serialize(), null, "script");
        return false;
    });
});