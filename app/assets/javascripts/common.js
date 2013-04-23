/*jslint browser: true, sloppy: true, todo: true, devel: true, white: true */
/*global $, Node, exitFullScreen, fullScreen */

// TODO: These variable names should be refactored to follow convention, i.e. only prepend with $ when it contains a jQuery object
var $content_box;
var $content_height;
var $content_top;
var $content_bottom;
var $model_width;
var $model_height;
var $model_start;
var $model_lowest;
var $header_height;
var $scroll_start;
var $scroll_end;

var minHeader, maxHeader, response_key;

function scroll_handler () {
    // Don't do anything if the model is taller than the info/assessment block.
    if ($content_height > $model_height) {
        if (($(document).scrollTop() > $scroll_start) && ($(document).scrollTop() < $scroll_end)) {
            // Case 1: moving with scroll: scrolling below header but not at bottom of info/assessment block
            // console.debug('Moving: ' + $(document).scrollTop() + ', set to ' + ($model_start + ($(document).scrollTop() - $scroll_start)));
            $('.model-container').css({'position': 'absolute', 'top': ($model_start + ($(document).scrollTop() - $scroll_start)) + 'px', 'width': $model_width});
        } else if ($(document).scrollTop() >= $scroll_end) {
            // Case 2: fixed to bottom
            // console.debug('Bottom: ' + $(document).scrollTop() + ', set to ' + $model_lowest);
            $('.model-container').css({'position': 'absolute', 'top': $model_lowest + 'px', 'width': $model_width});
        } else {
            // Case 3: fixed to top: scrolling shows some bit of header
            // console.debug('Top: ' + $(document).scrollTop() + ', set to ' + $model_start);
            $('.model-container').css({'position': 'absolute', 'top': $model_start + 'px', 'width': $model_width});
        }
    }
}

function calculateDimensions() {
    if ($('.text') && $('.model-container')) {
        // Content starts at the bottom of the header, so this is the height of the header too.
        // Handy as a marker for when to start scrolling.
        $header_height = $('#content').offset().top;
        // Height of info/assessment block
        $content_box = $('.text').height();
        $content_height = $content_box - parseInt($('.text').css('padding-top'), 10) - parseInt($('.text').css('padding-bottom'), 10);
        // Top of info/assessment block (starting position of interactive, topmost location)
        $content_top = $('.text').offset().top;
        // Bottom location of info/assessment block
        $content_bottom = $(document).height() - ($content_top + $content_height);
        // Interactive dimensions
        $model_height = $('.model-container').height();
        $model_width = $('.model-container').css('width');
        // Scroll starts here
        $scroll_start = $header_height;
        $model_start = ($content_top - $header_height);
        // Scroll ends here
        // The travel space available to the model is the height of the content block minus the height of the interactive, so the scroll-end is scroll start plus that value.
        $scroll_end = $scroll_start + ($content_height - $model_height);
        // Interactive lowest position: highest of the stop point plus start point (pretty much where you are at the end of the scroll) or fixed-to-top value
        $model_lowest = Math.max(($model_start + ($scroll_end - $scroll_start)), $model_start);
    }
}

$(window).resize(function () {
    calculateDimensions();
});

function showTutorial() {
    $('#overlay').fadeIn('fast');
    $('#tutorial').fadeIn('fast');
}

function setIframeHeight() {
    // This depends on a data-aspect_ratio attribute being set in the HTML.
    var aspectRatio = $('iframe[data-aspect_ratio]').attr('data-aspect_ratio'),
        targetHeight = $('.model, .model-edit').width() / aspectRatio;
    $('iframe[data-aspect_ratio]').height(targetHeight);
}

function adjustWidth() {
    var model_width, width;
    if ($('.content').css('width') === '960px') {
        model_width = '60%';
        width = '95%';
    } else {
        model_width = '576px';
        width = '960px';
    }

    $('#header div').css('width', width);
    $('.content').css('width', width);
    $('div.model').css('width', model_width);
    $('#footer div').css('width', width);
}

function nextQuestion(num) {
    var curr_q = '.q' + (num - 1),
        next_q = '.q' + num;
    $(curr_q).fadeOut('fast', function () { $(next_q).fadeIn(); });
}

function prevQuestion(num) {
    var curr_q = '.q' + (num + 1),
        next_q = '.q' + num;
    $(curr_q).fadeOut('fast', function () { $(next_q).fadeIn(); });
}

// Update the modal edit window with a returned partial
$(function () {
    $('[data-remote][data-replace]')
        .data('type', 'html')
        // TODO: live() is deprecated http://api.jquery.com/live/
        .live('ajax:success', function (event, data) {
            var $this = $(this);
            $($this.data('replace')).html(data.html);
            $this.trigger('ajax:replaced');
        });
});

$(document).ready(function () {
    // prepare for scrolling model
    if ($('.model-container').length) {
        calculateDimensions();
        $(document).bind('scroll', scroll_handler());
    }

    // add event listeners:
    // enable check answer when there is an answer
    $('input[type=radio]').click(function () {
        $('#check').removeClass('disabled');
    });
    // exit from fullscreen event
    $('#overlay').click(function () {
        exitFullScreen(); // Defined in full-screen.js
    });
    // enter fullscreen event
    $('.full-screen-toggle').click(function () {
        fullScreen();
        return false;
    });
    // submit multiple choice on change event
    // TODO: live() is deprecated http://api.jquery.com/live/
    $('.live_submit').live('change',function() {
      $(this).parents('form:first').submit();
    });
    // submit textarea on blur event
    // TODO: live() is deprecated http://api.jquery.com/live/
    $('textarea.live-submit').live('blur',function() {
      $(this).parents('form:first').submit();
    });

    // Adjust iframe to have correct aspect ratio
    setIframeHeight();

    // Set up sortable lists:
    // Embeddables in page edit
    $('#sort_embeddables').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: "GET",
                url: "reorder_embeddables",
                data: $("#sort_embeddables").sortable("serialize")
            });
        }
    });
    // Pages in activity edit
    $('#sort-pages').sortable({ handle: '.drag_handle',
        opacity: 0.8,
        tolerance: 'pointer',
        update: function () {
            $.ajax({
                type: "GET",
                url: "reorder_pages",
                data: $('#sort-pages').sortable("serialize")
            });
        }
    });
});
