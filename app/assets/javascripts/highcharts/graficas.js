$(function() {

    cadena='http://localhost:3000/users/'+ document.getElementById('user').value+'/actssamples.json'
    $.getJSON(cadena, function(data) {

        var start = + new Date();

        // Create the chart
        var chart = new Highcharts.StockChart({
            chart: {
                renderTo: 'container',
                zoomType: 'x'
            },

            rangeSelector: {
                selected: 4,
                buttonSpacing: 10,
                buttons: [{
                    type: 'hour',
                    count: 1,
                    text: '1h'
                }, {
                    type: 'day',
                    count: 1,
                    text: '1d'
                },{
                    type: 'week',
                    count: 1,
                    text: '1w'
                },{
                    type: 'month',
                    count: 1,
                    text: '1m'
                }, {
                    type: 'all',
                    text: 'All'
                }]
            },

            yAxis: {
                title: {
                    text: 'Activity Counts'
                },
                plotLines : [{
                    value : -1,
                    color : 'blue',
                    dashStyle : 'shortdash',
                    width : 2,
                    label : {
                        text : 'Sin lectura'
                    }
                }, {
                    value : 20,
                    color : 'red',
                    dashStyle : 'shortdash',
                    width : 2,
                    label : {
                        text : 'Sin movimiento'
                    }
                }, {
                    value : 100,
                    color : 'red',
                    dashStyle : 'shortdash',
                    width : 2,
                    label : {
                        text : 'Sedentaria'
                    }
                }, {
                    value : 1952,
                    color : 'orange',
                    dashStyle : 'shortdash',
                    width : 2,
                    label : {
                        text : 'Ligera'
                    }
                },  {
                    value : 5724,
                    color : 'green',
                    dashStyle : 'shortdash',
                    width : 2,
                    label : {
                        text : 'Moderada'
                    }
                }]
            },

            title: {
                text: 'Activity Counts'
            },


            scrollbar: {
                barBackgroundColor: 'gray',
                barBorderRadius: 7,
                barBorderWidth: 0,
                buttonBackgroundColor: 'gray',
                buttonBorderWidth: 0,
                buttonBorderRadius: 7,
                trackBackgroundColor: 'none',
                trackBorderWidth: 1,
                trackBorderRadius: 8,
                trackBorderColor: '#CCC'
            },
            series: [{
                name: 'Activity Counts',
                data: data,
                pointStart: document.getElementById('iniacts').value/1,
                pointInterval: 60 * 1000,
                tooltip: {
                    valueDecimals: 0,
                    valueSuffix: 'Activity Counts'
                }
            }]

        });
    });
});

/*
$(document).ready(function() {

   /* $.getJSON('localhost:3000/users/'+'7'+'/actssamples.json',	function(data) {
        seriesOptions = {
            data: data
        };
    });*/

/*
    seriesOptions=[2,3,4,5,6]
    chart1 = new Highcharts.StockChart({
        chart: {
            renderTo: 'container'
        },
        yAxis: {
            title: {
                text: 'Activity Counts'
            },
            plotLines : [{
                value : -1,
                color : 'blue',
                dashStyle : 'shortdash',
                width : 2,
                label : {
                    text : 'Sin lectura'
                }
            }, {
                value : 100,
                color : 'red',
                dashStyle : 'shortdash',
                width : 2,
                label : {
                    text : 'Sedentaria'
                }
            }, {
                value : 1952,
                color : 'orange',
                dashStyle : 'shortdash',
                width : 2,
                label : {
                    text : 'Ligera'
                }
            }]
        },

        rangeSelector: {
            selected: 4,
            buttonSpacing: 10,
            buttons: [{
                type: 'hour',
                count: 1,
                text: '1h'
            }, {
                type: 'day',
                count: 1,
                text: '1d'
            }, {
                type: 'month',
                count: 1,
                text: '1m'
            }, {
                type: 'all',
                text: 'All'
            }]
        },

        scrollbar: {
            barBackgroundColor: 'gray',
            barBorderRadius: 7,
            barBorderWidth: 0,
            buttonBackgroundColor: 'gray',
            buttonBorderWidth: 0,
            buttonBorderRadius: 7,
            trackBackgroundColor: 'none',
            trackBorderWidth: 1,
            trackBorderRadius: 8,
            trackBorderColor: '#CCC'
        },

        series: [{
            name: 'Activity Counts',
            data: seriesOptions,
            pointStart: Date.UTC(2004, 3, 1),
            pointInterval: 600 * 1000,
            tooltip: {
                valueDecimals: 2
            }
        }]


    });
});

*/