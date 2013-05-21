(function($) {
    $.timepicker.regional['ja'] = {
        timeOnlyTitle: '時間を選択',
        timeText: '時間',
        hourText: '時',
        minuteText: '分',
        secondText: '秒',
        millisecText: 'ミリ秒',
        timezoneText: 'タイムゾーン',
        currentText: '現時刻',
        closeText: '閉じる',
        timeFormat: 'HH:mm',
        amNames: ['午前', 'AM', 'A'],
        pmNames: ['午後', 'PM', 'P'],
        isRTL: false,
        prevText: '&#x3C;前',
        nextText: '次&#x3E;',
        monthNames: ['1月','2月','3月','4月','5月','6月',
        '7月','8月','9月','10月','11月','12月'],
        monthNamesShort: ['1月','2月','3月','4月','5月','6月',
        '7月','8月','9月','10月','11月','12月'],
        dayNames: ['日曜日','月曜日','火曜日','水曜日','木曜日','金曜日','土曜日'],
        dayNamesShort: ['日','月','火','水','木','金','土'],
        dayNamesMin: ['日','月','火','水','木','金','土'],
        weekHeader: '週',
        dateFormat: 'yy-mm-dd',
        firstDay: 0,
        showMonthAfterYear: true,
        yearSuffix: '年'
    };
    $.timepicker.setDefaults($.timepicker.regional['ja']);
})(jQuery);
