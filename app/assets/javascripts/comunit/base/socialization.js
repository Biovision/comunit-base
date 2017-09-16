'use strict';

document.addEventListener('DOMContentLoaded', function () {
    let $container = $('.follow-user-buttons');
    let url = $container.data('url');

    $container.find('.follow').on('click', function () {
        let $follow = $(this).parent().find('.follow');
        let $unfollow = $(this).parent().find('.unfollow');

        $.ajax(url, {
            method: 'put',
            success: function (response) {
                $follow.addClass('hidden');
                $unfollow.removeClass('hidden');
            }
        }).fail(Biovision.handle_ajax_failure);
    });

    $container.find('.unfollow').on('click', function () {
        let $follow = $(this).parent().find('.follow');
        let $unfollow = $(this).parent().find('.unfollow');

        $.ajax(url, {
            method: 'delete',
            success: function (response) {
                $follow.removeClass('hidden');
                $unfollow.addClass('hidden');
            }
        }).fail(Biovision.handle_ajax_failure);
    });

    $('.hide-request').on('click', function () {
        let $button = $(this);

        $.ajax($button.data('url'), {
            method: 'delete',
            success: function(response) {
                if (response.hasOwnProperty('data')) {
                    if (!response['data']['visible']) {
                        $button.closest('li').addClass('hidden');
                    }
                }
            }
        }).fail(Biovision.handle_ajax_failure);
    });
});
