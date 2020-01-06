$(function () {

    var ip = $("input[name=ip]").val();
    console.log(ip);
    $("#restart").click(function (event) {
        console.log('进入restart');
        $.post({
            'url': '/restart/',
            'data': {
                'action': "restart"
            },
            'success': function (data) {

            },
            'fail': function (error) {

            }
        });

    });
    $("#create").click(function (event) {
        console.log('进入create');
        $.get({
            'url': '/result_num/',
            'success': function (data) {
            },
            'fail': function (error) {
            }
        });
        window.open(
            'http://' + ip + '/results'
        )

    });
});