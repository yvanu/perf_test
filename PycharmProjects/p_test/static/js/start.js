
$(function () {
    $("#start_net").click(function (event) {
        console.log('进入start');
        var ip_1 = $("input[name=IP-1]").val();
        var ip_2 = $("input[name=IP-2]").val();
        console.error(ip_2);
        $.post({
            'url': '/start/',
            'data': {
                'ip_1':ip_1,
                'ip_2':ip_2
            },
            'success': function (data) {

            },
            'fail': function (error) {

            }
        });

    });

});
