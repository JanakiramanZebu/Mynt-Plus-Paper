// Datafeed implementation, will be added later
import Datafeed from './datafeed.js';
import { changeSymbol } from './streaming.js';
import {
	getIndicators,
	setIndicators,
} from './helpers.js';

var queryString = window.location.search;
var urlParams = new URLSearchParams(queryString);
var product = urlParams.get('symbol')
var uid = urlParams.get('user')
var res = urlParams.get('res')
var darkorlight = urlParams.get('dark')
// var showSeries = urlParams.get('showseries')
// showSeries = showSeries == 'Y' ? true : false
// localStorage.setItem('tradingview.current_theme.name', darkorlight == "true" ? "dark" : 'light');
var styleElement = document.createElement("style");
if (darkorlight == "true") {
	styleElement.appendChild(document.createTextNode("#spinnerDisplay{background-color: #000 !important;position: absolute;top: 0;left: 0;width:100vw;}#spinner { background: radial-gradient(farthest-side, #000 94%, #000) top/9px 9px no-repeat, conic-gradient(#ffffff 30%, #ffffff)!important; -webkit-mask: radial-gradient( farthest-side, #0000 calc(100% - 9px), #000 0 )!important; mask: radial-gradient(farthest-side, #0000 calc(100% - 9px), #000 0)!important;}"))
} else {
	styleElement.appendChild(document.createTextNode("#spinnerDisplay{background-color: #fff !important;position: absolute;top: 0;left: 0;width:100vw;}#spinner { background: radial-gradient(farthest-side, #000 94%, #0000) top/9px 9px no-repeat, conic-gradient(#0000 30%, #000)!important; -webkit-mask: radial-gradient( farthest-side, #0000 calc(100% - 9px), #000 0 )!important; mask: radial-gradient(farthest-side, #0000 calc(100% - 9px), #000 0)!important;}"));
}
document.getElementsByTagName("head")[0].appendChild(styleElement);
window.tvWidget = new TradingView.widget({
	symbol: `${product}`, // default symbol
	interval: res, // default interval
	fullscreen: true, // displays the chart in the fullscreen mode
	container: 'tv_chart_container',
	timezone: 'Asia/Kolkata',
	datafeed: Datafeed,
	autosize: true,
	// has_empty_bars:false,
	// debug:true,
	library_path: './charting_library/',
	custom_font_family: "Inter, monospace",
	// loading_screen: { backgroundColor: "black" },
	// custom_css_url: '../css/styles.css',
	// preset: "mobile",
	disabled_features: [ "header_compare", "end_of_period_timescale_marks", "header_symbol_search"], //"left_toolbar","bottom_toolbar","header_widget", "header_symbol_search"
	enabled_features: ["timeframes_toolbar", "symbol_info","study_templates", "countdown", "create_volume_indicator_by_default", "control_bar", "show_zoom_and_move_buttons_on_touch", "left_toolbar"], //hide_left_toolbar_by_default ,show_zoom_and_move_buttons_on_touch
	theme: darkorlight == "true" ? "dark" : 'light',
	// header_widget_buttons_mode: 'fullsize',
	study_count_limit: 5,
	charts_storage_url: 'https://chartbe.mynt.in',
	charts_storage_api_version: "1.1",
	client_id: uid,
	user_id: uid,
	// load_last_chart: true,
	// auto_save_delay: 5,
});



window.tvWidget.onChartReady(() => {
	window.tvWidget.activeChart().applyOverrides({
		"paneProperties.background": darkorlight == "true" ? '#131722' : '#ffffff',
		"paneProperties.backgroundGradientEndColor": darkorlight == "true" ? '#131722' : '#ffffff',
		"paneProperties.backgroundGradientStartColor": darkorlight == "true" ? '#131722' : '#ffffff',

		"paneProperties.horzGridProperties.color": darkorlight == "true" ? 'rgba(240, 243, 250, 0.06)' : 'rgba(42, 46, 57, 0.06)',
		"paneProperties.vertGridProperties.color": darkorlight == "true" ? 'rgba(240, 243, 250, 0.06)' : 'rgba(42, 46, 57, 0.06)',
		"scalesProperties.lineColor": darkorlight == "true" ? 'rgba(240, 243, 250, 0)' : 'rgba(42, 46, 57, 0)',
		"scalesProperties.textColor": darkorlight == "true" ? '#B2B5BE' : '#131722',

		// 'scalesProperties.showStudyPlotLabels': false,
		'mainSeriesProperties.showCountdown': true,
		// 'paneProperties.legendProperties.showStudyArguments': false,
		// 'paneProperties.legendProperties.showSeriesTitle': showSeries,
		// 'mainSeriesProperties.statusViewStyle.showExchange': showSeries,
		// 'mainSeriesProperties.statusViewStyle.showInterval': showSeries,
		//  'volume smooth.visible': false,
	});
	window.tvWidget.load();
	
});

var indicator = await getIndicators();

setInterval(async function () {
	var d = window.tvWidget.activeChart().getAllStudies();
	var c = [];
	for (var i = 0; i < d.length; i++) {
		var a = d[i].name;
		if (a != "Volume") {
			c.push(a);
		}
	}
	if (JSON.stringify(indicator.data) != JSON.stringify(c)) {
		try {
			let res = await setIndicators(c)
			indicator = res;
		}
		catch (e) {
			console.log(e);
		}
	}
}, 5000);


// setTimeout(() => {
// @theme change
// window.tvWidget.activeChart().applyOverrides({
// 	"paneProperties.background": darkorlight != "true" ? '#131722' : '#ffffff',
// 	"paneProperties.backgroundGradientEndColor": darkorlight != "true" ? '#131722' : '#ffffff',
// 	"paneProperties.backgroundGradientStartColor": darkorlight != "true" ? '#131722' : '#ffffff',

// 	"paneProperties.horzGridProperties.color": darkorlight != "true" ? 'rgba(240, 243, 250, 0.06)' : 'rgba(42, 46, 57, 0.06)',
// 	"paneProperties.vertGridProperties.color": darkorlight != "true" ? 'rgba(240, 243, 250, 0.06)' : 'rgba(42, 46, 57, 0.06)',
// 	"scalesProperties.lineColor": darkorlight != "true" ? 'rgba(240, 243, 250, 0)' : 'rgba(42, 46, 57, 0)',
// 	"scalesProperties.textColor": darkorlight != "true" ? '#B2B5BE' : '#131722',
// });
// }, 5000);




function changeScript(symbol, token, theme) {
	// document.getElementById('spinnerDisplay').style.display = 'flex';
	const url = new URL(window.location.href); // Get the current URL
	url.searchParams.set('symbol', symbol);
	url.searchParams.set('token', token);
	url.searchParams.set('exch', symbol.split(":")[0]);
	url.searchParams.set('dark', theme == 'Y' ? true : false);
	window.history.pushState({}, '', url);
	
	// if (symbol.split(":")[1] == window.tvWidget.activeChart().symbol()) {
	// 	document.getElementById('spinnerDisplay').style.display = 'none';
	// }
	// console.log("symbol set", symbol)
	window.tvWidget.activeChart().applyOverrides({
		"paneProperties.background": theme == 'Y' ? '#131722' : '#ffffff',
		"paneProperties.backgroundGradientEndColor": theme == 'Y' ? '#131722' : '#ffffff',
		"paneProperties.backgroundGradientStartColor": theme == 'Y' ? '#131722' : '#ffffff',

		"paneProperties.horzGridProperties.color": theme == 'Y' ? 'rgba(240, 243, 250, 0.06)' : 'rgba(42, 46, 57, 0.06)',
		"paneProperties.vertGridProperties.color": theme == 'Y' ? 'rgba(240, 243, 250, 0.06)' : 'rgba(42, 46, 57, 0.06)',
		"scalesProperties.lineColor": theme == 'Y' ? 'rgba(240, 243, 250, 0)' : 'rgba(42, 46, 57, 0)',
		"scalesProperties.textColor": theme == 'Y' ? '#B2B5BE' : '#131722',

		// 'scalesProperties.showStudyPlotLabels': false,
		'mainSeriesProperties.showCountdown': true,
		// 'paneProperties.legendProperties.showStudyArguments': false,
		// 'paneProperties.legendProperties.showSeriesTitle': showSeries,
		// 'mainSeriesProperties.statusViewStyle.showExchange': showSeries,
		// 'mainSeriesProperties.statusViewStyle.showInterval': showSeries,
		//  'volume smooth.visible': false,
	})
	window.tvWidget.setSymbol(symbol, window.tvWidget.activeChart().resolution(), () => null)
	changeSymbol(symbol);
}

if (indicator.data) {
	for (var i = 0; i < indicator.data.length; i++) {
		console.log(indicator['data'][0])
		window.tvWidget.activeChart().createStudy(indicator['data'][i], false, false);
	}
}



window.changeScript = changeScript;