$(function() {
  var lastSearch = '';
  var isBlankish = function() {
    return $('input').val().length <= 1;
  };

  var jsonUrl = function() {
    return 'http://' + window.location.hostname + '/companies/' + encodeURI($('input').val());
  };

  var onSearchBoxInput = function(event) {
    if(isBlankish()) {
      $('.go.button').removeClass('ready');
    } else {
      $('.go.button').addClass('ready');
    }

    $('.raw-url').text('Call the api with ' + jsonUrl());

    if(event.keyCode == 13) {
      event.preventDefault();
      if(lastSearch != $('input').val()) {
        $('.go.button').trigger('click');
        lastSearch = $('input').val()
      }
      return false;
    }
  };

  var colourFromSentiment = function(sentiment) {
    if(sentiment < -0.5) { return 'red' };
    if(sentiment > 0.5) { return 'green' };
    return 'black'
  }

  var onSearchBoxSubmit = function() {
    $('.results').slideUp();
    var button = $(this);
    if(button.hasClass('ready')) {

      $.getJSON(jsonUrl(), function(data) {

        button.text('Go');
        button.addClass('ready');
        $('input').attr('disabled', false);
        $('.results .company').text($('input').val());
        $('.results .summary').html('');
        $('.results .tweets').html('');
        $.each(data['twitter']['tweets'], function(index, tweet) {
          $('.results .tweets').append('<p class=' + colourFromSentiment(tweet.sentiment) + '>' + tweet.text + '</p>')
        });
        $.each(data['twitter']['overall_feeling'], function(key, value) {
          $('.results .summary').append('<p class=' + colourFromSentiment(value) + '>' + key + ': ' + value + '<p>');
        });
        $('.results').slideDown();
      });

      button.text('loading...');
      button.removeClass('ready');
      $('input').attr('disabled', true);
    }
  };


  $('input').on('keyup keypress', onSearchBoxInput);
  $('.go.button').on('click', onSearchBoxSubmit);
});