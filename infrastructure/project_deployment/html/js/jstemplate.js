// Set 'URL' to your API Gateway endpoint
URL = "${url}";
$(document).ready(function () {

    $("#mainForm").submit(function (e) {
        e.preventDefault();
        
        var first_name = $("#first_name").val(),
            last_name = $("#last_name").val(),
            email = $("#email").val(),
            ordertype = $("#ordertype").val(),
            custom = $("#custom").val();
        $.ajax({
            type: "POST",
            url: URL,
            contentType: 'application/json',
            crossDomain: true, 
            dataType: 'json',
            data: JSON.stringify({
                first_name: first_name,
                last_name: last_name,
                email: email,
                ordertype: ordertype,
                custom: custom
            })
        }).done(function (result) {
            console.log(result);
        }).fail(function (jqXHR, textStatus, error) {
            console.log("Post error: " + error);
            if (error != '') $('#form-response').text('Error: ' + error);
        }).always(function(data) {
            console.log(JSON.stringify(data));
            $('#form-response').text('Response recorded');
        });

    });
});