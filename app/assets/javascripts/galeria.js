$(document).ready(function(){
	function ie8SafePreventEvent(e){
	    if(e.preventDefault){ e.preventDefault()}
	    else{e.stop()};
	    e.returnValue = false;
	    e.stopPropagation();    
	}
	function center(value){	
	    d=value;
		mv = (d.parent().width()-d.width())/2;
		mh = (d.parent().height()-d.height())/2;
		d.css("margin-left", mv)
		d.css("margin-top", mh)
	}
	
	
	if($(".galleria").length > 0){
		
		if ($(".galleria a").length>4){
			z = Math.round((Math.floor($(".galleria a").length/2))/4)*4;
			$(".galleria a:nth-child("+z+")").after('<div class="stage"><img class="image_cont"></div>');
		}else{	
	        $(".galleria").prepend('<div class="stage"><img class="image_cont"></div>'); 
		}

	    $(".galleria .stage img").css({'z-index': 1});
		$(".galleria a img").each(function(index, value){
			o = jQuery(value);
			o.css('position', "relative");
		    o.parent().addClass("inactive");
			center(o)});
		
		$(".image_cont").attr("src", $(".galleria a").first().attr("data-pre"));
		t = $(".galleria a").first();
		t.removeClass("inactive").addClass("active");
		
		$(".galleria a").mouseover(function(e){
		   if ( t != e.currentTarget){
		   t = e.currentTarget;	
	       
		   var newSrc = jQuery(t).attr("data-pre");
	       image = new Image();    

		    image.onload = function() {
		        $(".image_cont").fadeOut(200, function() {
		            $(this).attr("src", newSrc).fadeIn(200);
		        });
		    }
		    image.src = newSrc;
			$(".galleria a.active").removeClass("active").addClass("inactive");
			$(this).removeClass("inactive").addClass("active");
			}
			ie8SafePreventEvent(e);		
		});
		
	}

});