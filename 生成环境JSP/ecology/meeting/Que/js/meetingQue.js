function scoreFun(object, opts, inputobj) {
	var defaults = {
		fen_d : 34,
		ScoreGrade : 5,
		nameScore : "fenshu",
		parent : "star_score",
	};
	options = $.extend( {}, defaults, opts);
	var countScore = object.find("." + options.nameScore);
	var startParent = object.find("." + options.parent);
	var now_cli;
	var fen_cli;
	var fen_d = options.fen_d;
	var len = options.ScoreGrade;
	startParent.width(fen_d * len);
	var preA = (5 / len);
	for ( var i = 0; i < len; i++) {
		var newSpan = $("<a href='javascript:void(0)'></a>");
		newSpan.css( {
			"left" : 0,
			"width" : fen_d * (i + 1),
			"z-index" : len - i
		});
		newSpan.appendTo(startParent)
	}
	startParent.find("a").each(function(index, element) {
		$(this).click(function() {
			now_cli = index;
			show(index, $(this))
		});
		$(this).mouseenter(function() {
			show(index, $(this))
		});
		$(this).mouseleave(function() {
			if (now_cli >= 0) {
				var scor = preA * (parseInt(now_cli) + 1);
				startParent.find("a").removeClass("clibg");
				startParent.find("a").eq(now_cli).addClass("clibg");
				var ww = fen_d * (parseInt(now_cli) + 1);
				startParent.find("a").eq(now_cli).css( {
					"width" : ww,
					"left" : "0"
				});
				if (countScore) {
					countScore.text(scor);
					inputobj.val(scor);
				}
			} else {
				startParent.find("a").removeClass("clibg");
				if (countScore) {
					countScore.text("0")
				}
			}
		})
	});
	function show(num, obj) {
		var n = parseInt(num) + 1;
		var lefta = num * fen_d;
		var ww = fen_d * n;
		var scor = preA * n;
		object.find("a").removeClass("clibg");
		obj.addClass("clibg");
		obj.css( {
			"width" : ww,
			"left" : "0"
		});
		countScore.text(scor);
	}
};

function computeAverageScore(){
	var h_workflowScore = parseFloat($("#h_workflowScore").val());
	var h_resourcesScore = parseFloat($("#h_resourcesScore").val());
	var h_timeScore = parseFloat($("#h_timeScore").val());
	var h_implScore = parseFloat($("#h_implScore").val());
	var h_phyScore = parseFloat($("#h_phyScore").val());
	var h_companyScore = parseFloat($("#h_companyScore").val());
	
	var totalScore = h_workflowScore + h_resourcesScore + h_timeScore + h_implScore + h_phyScore + h_companyScore;
	var averageScore = (totalScore / 6);
	var h_averageScore = averageScore.toFixed(1);
	
	$("#h_averageScore").val(h_averageScore);
	$("#p_averageScore_show").text(h_averageScore);
	$("#p_atar_Show").attr("tip", h_averageScore);
	$(".show_number li p").each(function(index, element) {
	    var num = $(this).attr("tip");
	    var www = num * 2 * 17;
	    $(this).css("width",www);
	});
}