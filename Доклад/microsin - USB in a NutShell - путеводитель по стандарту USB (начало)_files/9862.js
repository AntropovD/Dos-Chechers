var ADILoader=ADILoader||function(){return{proxy_args:[],key:"",ip:"",settings:[],loaders:[],stackFn:[],log:"",debugid:"ADILoaderDebugConsole",cookie_matching_urls:[],_uuid:"",getPublicKey:function(){return"-----BEGIN PUBLIC KEY-----\nMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDLRaNhlttne/zP2+QK9xbpCgM6\n7LZkJAJPMEOHtYSjsdUaim3VxrpDT2bg2+JL9QJK5BcuHELOmyrLBuRDnXocQC8s\nV67wHuXcIegMN1qLNkm6IRg7ICdilEmuNqBABCVwzgGz+CxSlUvjrCiaFgVEWDNJ\n6WfNGM6Uj6BBaAIlJQIDAQAB\n-----END PUBLIC KEY-----"},init:function(a){a=
this.setDefault(a);this.settings[a.id]=a;a.processing&&(ADILoader.once("setDataHistory",function(){ADILoader.history.setData()}),document.getElementById(a.prefix+"DIV_"+a.id)||document.write('<div id="'+a.prefix+"DIV_"+a.id+'">'+(a.adLink?'<div id="'+a.prefix+"PL_"+a.id+'">'+a.adLink+"</div>":"")+"</div>"),this.trace(a.id,"Settings",a))},setDefault:function(a){1!==a.mobile_alernative||this.isMobile()||(a.mobile_alernative=0);a.processing=1;1!==a.mobile_only||this.isMobile()||(a.processing=0);return a},
setProxyArgs:function(a){this.proxy_args=a},getUserTime:function(){var a=Date().toString().split(" ");a.pop();a.pop();return a.join(" ")},getMetaTag:function(a){for(var c=document.getElementsByTagName("meta"),b=0;b<c.length;b++)if(c[b].getAttribute("name")==a)return c[b].getAttribute("content");return""},getTimestamp:function(){return(new Date).getTime()},getPixel:function(a){var c=document.createElement("img");c.setAttribute("src",a);c.setAttribute("alt","pixel");c.setAttribute("height","1px");c.setAttribute("width",
"1px");c.style.display="none";return c},afterDraw:function(a){this.trace(a.infid,"afterDraw","OK");if(this.cookie_matching_urls)for(var c in this.cookie_matching_urls){var b=this.getPixel(this.cookie_matching_urls[c]);a.target().appendChild(b)}this.displayLog();this.history.init(a.infid)},cookieMatching:function(a){this.cookie_matching_urls=a},displayLog:function(){if(this.log){var a=document.getElementById(this.debugid);a||(a=document.createElement("div"),a.id=this.debugid,a.style.position="absolute",
a.style.top="1px",a.style.left="1px",a.style.background="#FFAA00",a.style.padding="5px",a.style.width="99%",a.style.height="150px",a.style.overflowY="scroll",a.innerHTML="",document.body.appendChild(a));a.innerHTML=this.log}},trace:function(a,c,b){if("undefined"!==typeof this.settings[a]&&1===this.settings[a].debug){var d="";if("object"==typeof b)for(var e in b)"source"!=e&&(d+=e+": "+b[e]+"; ");else d=b;this.log+="ID: "+a+"; <b>"+c+"</b> => <i>"+d+"</i><br/>";this.displayLog()}},cookies:{set:function(a,
c,b,d){var e="";b&&(e=new Date,e.setTime(e.getTime()+864E5*b),e="; expires="+e.toGMTString());b="";d&&(b="; domain="+d+";");document.cookie=a+"="+encodeURIComponent(c)+e+"; path=/"+b},get:function(a){if(a)return(a=document.cookie.match(RegExp("(?:^|; )"+a+"=([^\\s;]*)")))?decodeURIComponent(a[1]):null},remove:function(a){this.cookies.set(a,"",-1)}},getData:function(a,c){this.trace(c,"Switch Responce",a);var b=this.loaders[c];if("undefined"!==typeof a.other_code&&"undefined"!==typeof b.DrawOtherCode)b.DrawOtherCode(a.other_code);
else{b="";if(0<this.proxy_args.length)for(i in this.proxy_args){for(var d in this.proxy_args[i])break;b+="&"+d+"="+this.proxy_args[i][d]}var e=this.cookies.get("rtb_bonus"),e=null===e?"":"&b="+e,f=this.cookies.get("rtb_exchange"),f=null===f?"":"&x="+f;d=document.createElement("script");d.type="text/javascript";var g="";a.hasOwnProperty("data")&&(g+="&d="+a.data);a.hasOwnProperty("networks")&&(g+="&w="+a.networks);var h=a.net.split(":");if(h instanceof Array&&1<h.length)for(var l=0;l<h.length;l++){var m=
"d"+h[l];a.hasOwnProperty(m)&&(g+="&"+m+"="+a[m])}g+="&s="+ADILoader.settings[c].mobile_alernative;h=new Date;h="&t="+h.getYear()+h.getMonth()+h.getDay()+h.getHours()+h.getMinutes()+h.getSeconds();d.async=!0;d.src=a.url+"/"+c+".js?param="+a.param+"&net="+a.net+g+e+f+h+b;ADILoader.trace(c,"Proxy Request",d.src);b=document.getElementsByTagName("script")[0];b.parentNode.insertBefore(d,b||null)}},isMobile:function(){var a=!1,c=navigator.userAgent||navigator.vendor||window.opera;if(/(android|bb\d+|meego).+mobile|avantgo|bada\/|blackberry|blazer|compal|elaine|fennec|hiptop|iemobile|ip(hone|od)|iris|kindle|lge |maemo|midp|mmp|mobile.+firefox|netfront|opera m(ob|in)i|palm( os)?|phone|p(ixi|re)\/|plucker|pocket|psp|series(4|6)0|symbian|treo|up\.(browser|link)|vodafone|wap|windows (ce|phone)|xda|xiino/i.test(c)||
/1207|6310|6590|3gso|4thp|50[1-6]i|770s|802s|a wa|abac|ac(er|oo|s\-)|ai(ko|rn)|al(av|ca|co)|amoi|an(ex|ny|yw)|aptu|ar(ch|go)|as(te|us)|attw|au(di|\-m|r |s )|avan|be(ck|ll|nq)|bi(lb|rd)|bl(ac|az)|br(e|v)w|bumb|bw\-(n|u)|c55\/|capi|ccwa|cdm\-|cell|chtm|cldc|cmd\-|co(mp|nd)|craw|da(it|ll|ng)|dbte|dc\-s|devi|dica|dmob|do(c|p)o|ds(12|\-d)|el(49|ai)|em(l2|ul)|er(ic|k0)|esl8|ez([4-7]0|os|wa|ze)|fetc|fly(\-|_)|g1 u|g560|gene|gf\-5|g\-mo|go(\.w|od)|gr(ad|un)|haie|hcit|hd\-(m|p|t)|hei\-|hi(pt|ta)|hp( i|ip)|hs\-c|ht(c(\-| |_|a|g|p|s|t)|tp)|hu(aw|tc)|i\-(20|go|ma)|i230|iac( |\-|\/)|ibro|idea|ig01|ikom|im1k|inno|ipaq|iris|ja(t|v)a|jbro|jemu|jigs|kddi|keji|kgt( |\/)|klon|kpt |kwc\-|kyo(c|k)|le(no|xi)|lg( g|\/(k|l|u)|50|54|\-[a-w])|libw|lynx|m1\-w|m3ga|m50\/|ma(te|ui|xo)|mc(01|21|ca)|m\-cr|me(rc|ri)|mi(o8|oa|ts)|mmef|mo(01|02|bi|de|do|t(\-| |o|v)|zz)|mt(50|p1|v )|mwbp|mywa|n10[0-2]|n20[2-3]|n30(0|2)|n50(0|2|5)|n7(0(0|1)|10)|ne((c|m)\-|on|tf|wf|wg|wt)|nok(6|i)|nzph|o2im|op(ti|wv)|oran|owg1|p800|pan(a|d|t)|pdxg|pg(13|\-([1-8]|c))|phil|pire|pl(ay|uc)|pn\-2|po(ck|rt|se)|prox|psio|pt\-g|qa\-a|qc(07|12|21|32|60|\-[2-7]|i\-)|qtek|r380|r600|raks|rim9|ro(ve|zo)|s55\/|sa(ge|ma|mm|ms|ny|va)|sc(01|h\-|oo|p\-)|sdk\/|se(c(\-|0|1)|47|mc|nd|ri)|sgh\-|shar|sie(\-|m)|sk\-0|sl(45|id)|sm(al|ar|b3|it|t5)|so(ft|ny)|sp(01|h\-|v\-|v )|sy(01|mb)|t2(18|50)|t6(00|10|18)|ta(gt|lk)|tcl\-|tdg\-|tel(i|m)|tim\-|t\-mo|to(pl|sh)|ts(70|m\-|m3|m5)|tx\-9|up(\.b|g1|si)|utst|v400|v750|veri|vi(rg|te)|vk(40|5[0-3]|\-v)|vm40|voda|vulc|vx(52|53|60|61|70|80|81|83|85|98)|w3c(\-| )|webc|whit|wi(g |nc|nw)|wmlb|wonu|x700|yas\-|your|zeto|zte\-/i.test(c.substr(0,
4)))a=!0;return a},getUserAgent:function(){return navigator.userAgent||navigator.vendor||window.opera},getLanguage:function(){return navigator.language||navigator.userLanguage},gerReferer:function(){return document.referrer},beforeDraw:function(a,c){this.trace(a,"beforeDraw","OK");this.trace(a,"beforeDrawDATA",c);var b=this.loaders[a];c.clearbs&&this.cookies.set("rtb_bonus","",1);c.clearex&&this.cookies.set("rtb_exchange","",1);c.bonus&&this.setLastTwentyIDS(c.bonus,"rtb_bonus");c.exchange&&this.setLastTwentyIDS(c.exchange,
"rtb_exchange");if(0===c.source.length)return this.trace(a,"beforeDrawDATA","source.length = 0; Exit;"),b.target().innerHTML="",-1;if(c.dummy_code&&1==c.dummy_code)return b.innerHTML="",this.DrawOtherCode(a,c.source),-1;if(this.settings[a].mobile_alernative)return this.trace(a,"MobileAlernative","OK"),this.attachedInTheFooter(b,c),-1;var d=document.getElementById(b.pl_id);d&&b.target().removeChild(d);return 1},DrawOtherCode:function(a,c){this.trace(a,"DrawOtherCode","OK");var b=this.loaders[a],d=
document.getElementById(b.pl_id);d&&b.target().removeChild(d);var e=function(){var a=g.body.offsetHeight||g.body.clientHeight||g.body.scrollHeight,d=g.body.offsetWidth||0,c=g.body.clientWidth||0,k=g.body.scrollWidth||0;d<c&&(d=c);d<k&&(d=k);0===a&&window.setTimeout(function(){e.call(b)},1E3);f.style.width=d+"px";f.style.height=a+"px";f.style.visibility="";ADILoader.showLoadDiv(b.infid,"Loading...",!0)},f=document.getElementById(b.ifr_id);if(f){var g=f.contentWindow.document;g.open();g.innerHtml="";
f.style.visibility="hidden";this.showLoadDiv(a,"Loading...")}else this.showLoadDiv(a,"Loading..."),f=document.createElement("iframe"),f.id=b.ifr_id,f.scrolling="no","undefined"!==typeof f.frameBorder&&(f.frameBorder="0"),"undefined"!==typeof f.marginHeight&&(f.marginHeight="0"),"undefined"!==typeof f.marginWidth&&(f.marginWidth="0"),f.style.border="none",f.style.height="auto",f.style.visibility="hidden",f.allowtransparency="true",b.target().appendChild(f),g=f.contentWindow.document,g.open();this.addEvent("load",
f.contentWindow||f.contentDocument.parentWindow,function(){e.call(b);window.setTimeout(function(){e.call(b)},3E3);window.setTimeout(function(){e.call(b)},6E3)},b.infid,"iframeWindow");g.writeln(c);g.close()},setLastTwentyIDS:function(a,c){var b=this.cookies.get(c),b=(null===b?a:a+":"+b).split(":"),b=this.unique(b);20<b.length&&(b=b.slice(0,20));b=b.join(":");this.cookies.set(c,b,1)},unique:function(a){for(var c=[],b=[],d=0;d<a.length;d++)void 0===b[a[d]]&&c.push(a[d]),b[a[d]]=!0;return c},doSwitch:function(a,
c){this.trace(a,"doSwitch: START","OK");this.loaders[a]=c;if(c.target()&&this.settings[a].processing){this.trace(a,"doSwitch: TARGET","OK");c.searchStr=this.referrer_keyword_parser();var b="?d="+this.getTimestamp(),d=this.settings[a].test_mode&&this.settings[a].test_network?"&n="+this.settings[a].test_network:"",e="&u="+this.getUserAgent(),f="&g="+this.getLanguage(),g="&f="+encodeURIComponent(this.gerReferer()),h="&k="+this.getMetaTag("keywords"),l="&i="+this.ip,m="&m="+this.settings[a].mobile_alernative,
k=document.createElement("script");k.type="text/javascript";k.async=!0;k.src="//"+c.urlToSwitch+"/"+a+".js"+b+d+e+f+g+h+l+m+c.searchStr;ADILoader.trace(a,"Switch Request",k.src);b=document.getElementsByTagName("script")[0];b.parentNode.appendChild(k,b)}},referrer_keyword_parser:function(){var a="",c="",b="",d=[[/^http([s]{0,1}):\/\/([a-z]+\.)?google\.(co\.)?[a-z]+/,/q=([^&]+)/,1],[/^http([s]{0,1}):\/\/([a-z]+\.)?yahoo\.(co\.)?[a-z]+/,/p=([^&]+)/,2],[/^http([s]{0,1}):\/\/([a-z]+\.)?search\.msn\.(co\.)?[a-z]+/,
/q=([^&]+)/,3],[/^http([s]{0,1}):\/\/([a-z]+\.)?search\.live\.(co\.)?[a-z]+/,/q=([^&]+)/,4],[/^http([s]{0,1}):\/\/([a-z]+\.)?search\.aol\.(co\.)?[a-z]+/,/q=([^&]+)/,5],[/^http([s]{0,1}):\/\/([a-z]+\.)?search\.ask\.[a-z]+/,/q=([^&]+)/,6],[/^http([s]{0,1}):\/\/([a-z]+\.)?search\.lycos\.(co\.)?[a-z]+/,/query=([^&]+)/,7],[/^http([s]{0,1}):\/\/([a-z]+\.)?digg\.com/,/s=([^&]+)/,8],[/^http([s]{0,1}):\/\/([a-z]+\.)?rambler\.[a-z]+/,/query=([^&]+)/,9],[/^http([s]{0,1}):\/\/([a-z]+\.)?yandex\.[a-z]+/,/text=([^&]+)/,
10],[/^http([s]{0,1}):\/\/([a-z]+\.)?bing\.(co\.)?[a-z]+/,/q=([^&]+)/,11],[/^http([s]{0,1}):\/\/([a-z]+\.)?localhost?\.(dev\.)?[a-z]+/,/q=([^&]+)/,100]],e,f;for(f in d)e=d[f],this.gerReferer().match(e[0])&&(c=e[2],a=this.gerReferer().match(e[1]),null!==a&&a.length&&(b=a[1]),a="&ssite="+c+"&query="+b);return a},addEvent:function(a,c,b,d,e){null===c?this.trace(d,"addEvent","ERROR!"):c.addEventListener?(this.trace(d,e+" addEventListener on"+a,"OK"),c.addEventListener(a,b,!1)):(this.trace(d,e+" attachEvent on"+
a,"OK"),c.attachEvent("on"+a,b))},showLoadDiv:function(a,c,b){this.trace(a,"showLoadDiv","OK");a=this.loaders[a];"undefined"===typeof b&&(b=!1);var d=document.getElementById(a.ld_id);d?d.innerHTML=c:(d=document.createElement("div"),d.innerHTML=c,d.id=a.ld_id,d.style.fontSize="12pt",a.target().insertBefore(d,a.target().childNodes[0]||null));d.style.display=b?"none":""},attachedInTheFooter:function(a,c){this.trace(a.infid,"attachedInTheFooter","OK");var b=function(){var a=this;ADILoader.trace(a.infid,
"swf.call","OK");var c=e.body.offsetHeight||e.body.clientHeight||e.body.scrollHeight,c=c+5;0===c&&window.setTimeout(function(){b.call(a)},1E3);d.style.height=c+"px";d.style.visibility="";ADILoader.showLoadDiv(a.infid,"Loading...",!0);f.style.height=c+"px"},d=document.getElementById(a.ifr_id);if(d){this.trace(a.infid,"iframe found",a.ft_id);var e=d.contentWindow.document;e.open();e.innerHtml="";d.style.visibility="hidden";this.showLoadDiv(a.infid,"Loading...");var f=document.getElementById(a.ft_id)}else this.showLoadDiv(a.infid,
"Loading..."),d=document.createElement("iframe"),f=document.createElement("div"),f.id=a.ft_id,document.body.appendChild(f),this.trace(a.infid,"Create new iframe",a.ifr_id),d.id=a.ifr_id,d.scrolling="no","undefined"!==typeof d.frameBorder&&(d.frameBorder="0"),"undefined"!==typeof d.marginHeight&&(d.marginHeight="0"),"undefined"!==typeof d.marginWidth&&(d.marginWidth="0"),d.style.border="none",d.width="100%",d.style.bottom=0,d.style.left=0,d.style.position="absolute",d.style.height="auto",d.style.visibility=
"hidden",d.allowtransparency="true",a.target().style.position="fixed",a.target().style.bottom=0,a.target().style.left=0,a.target().style.zIndex=9999,a.target().style.width="100%",a.target().appendChild(d),e=d.contentWindow.document,e.open();this.addEvent("load",d.contentWindow||d.contentDocument.parentWindow,function(){b.call(a)},a.infid,"iframeWindow");e.writeln(c.source);e.close();this.afterDraw(a)},setIP:function(a){this.ip=a},uuid:function(a,c){this.cookies.set("uuid",c,30,"."+document.domain)},
setUUID:function(a){this._uuid=a},getUUID:function(){return this._uuid},history:{session:[],data:{},setData:function(){this.data={date:ADILoader.getUserTime(),startTime:ADILoader.getTimestamp(),endTime:0,uuid:ADILoader.cookies.get("uuid"),IP:ADILoader.ip,protocol:document.location.protocol,host:window.location.host,pageUrl:encodeURIComponent(document.URL),referer:encodeURIComponent(ADILoader.gerReferer()),screen:{width:window.screen.width,height:window.screen.height,availWidth:window.screen.availWidth,
availHeight:window.screen.availHeight,pixelDepth:window.screen.pixelDepth,colorDepth:window.screen.colorDepth},navigator:{appVersion:navigator.appVersion,cookieEnabled:navigator.cookieEnabled,language:ADILoader.getLanguage(),platform:navigator.platform,userAgent:ADILoader.getUserAgent(),vendor:navigator.vendor,isMobile:/Android|webOS|iPhone|iPad|iPod|BlackBerry|IEMobile|Opera Mini/i.test(ADILoader.getUserAgent())},mouse:{isMove:!1,moveCount:0},informers:[]}},init:function(a){"undefined"!==typeof Storage&&
(ADILoader.settings[a].debug||ADILoader.settings[a].test_mode?window.localStorage.removeItem("rtb_uuid_history"):(ADILoader.once("sendHistory",function(){ADILoader.history.send()}),this.data.informers.push({informerId:a,sid:ADILoader.settings[a].sid,prefix:ADILoader.settings[a].prefix,clicks:[]}),ADILoader.once("saveHistory",function(){window.setInterval(function(){ADILoader.history.save()},500)}),ADILoader.once("onMouseMove",function(){ADILoader.addEvent("mousemove",window,function(){ADILoader.history.data.mouse.isMove=
!0;ADILoader.history.data.mouse.moveCount+=1})})))},addClick:function(a,c){for(var b in ADILoader.history.data.informers)ADILoader.history.data.informers[b].informerId==a&&ADILoader.history.data.informers[b].clicks.push({time:ADILoader.getTimestamp(),link:encodeURIComponent(c)});return!0},save:function(){ADILoader.history.data.endTime=ADILoader.getTimestamp();window.localStorage.setItem("rtb_uuid_history",btoa(JSON.stringify(ADILoader.history.data)))},send:function(){}},once:function(a,c){void 0===
this.stackFn[a]&&(this.stackFn[a]=a,c.call())}}}();


ADILoader.setUUID("241506a7-66ab-4367-8790-6095d0d56692");
ADILoader.cookieMatching(['//track.recreativ.ru/mtch.php?nid=15&psid=' + ADILoader.getUUID(), '//p.tpm.pw/sync?ssp=546042&m=r&extid='+ADILoader.getUUID()]);
ADILoader.setIP("212.193.78.149");
ADILoader.init({"id":9862,"sid":5,"type":80,"prefix":"RTB","adLink":null,"debug":0,"test_mode":0,"test_network":0,"mobile_alernative":0,"mobile_only":0});
//<script type="text/javascript">
/*rtbsystem.com/beta*/
var rtbLoader9862 = {
    infid   : '9862',      
  id      : 'RTBDIV_9862',
  ifr_id  : 'RTBIFR_9862',
  ld_id   : 'RTB_LD_9862',
  pl_id   : 'RTBPL_9862',
  ft_id   : 'RTBFT_9862',
  cl_id   : 'RTBCL_9862',
  urlToSwitch  : 'switch.rtbsystem.com',
  searchStr: '',
      target : function() {
        return document.getElementById(this.id);
    },
    targetIfr : function() {
        return document.getElementById(this.id);
    },
      doSwitch : function () {
      ADILoader.doSwitch(9862, this);
    },
      getData : function(swData) {
        ADILoader.getData(swData, 9862);
    },
      showLoadDiv : function(text,hide) {
        ADILoader.showLoadDiv(9862,text,hide);
    },
	draw : function (data) {
                
                if(ADILoader.beforeDraw(9862, data) == -1){
                    return;
                }
		var _this = this;
		var swf = function(){
			var sh = iw.body.offsetHeight || iw.body.clientHeight || iw.body.scrollHeight;
			var sw = iw.body.scrollWidth;
			if(sh === 0)
			{
				setTimeout(function(){
					swf.call(_this);
				},1000);
			}
			ifr.style.width = sw+"px";
			ifr.style.height = sh+"px";
			ifr.style.visibility="";
			this.showLoadDiv('Loading...',true);
		};
		
		var ifr = document.getElementById(this.ifr_id);
		if(ifr)
		{
			var iw = ifr.contentWindow.document;
			iw.open();
			iw.innerHtml = "";
			ifr.style.visibility='hidden';
			this.showLoadDiv("Loading...");
		}
		else
		{
			this.showLoadDiv("Loading...");
			var ifr= document.createElement('iframe');
			ifr.id= this.ifr_id;
			ifr.width = data.width;
			ifr.scrolling = "no";
			if(typeof ifr.frameBorder !== 'undefined')
				ifr.frameBorder = "0";
			if(typeof ifr.marginHeight !== 'undefined')
				ifr.marginHeight = "0";
			if(typeof ifr.marginWidth !== 'undefined')
				ifr.marginWidth = "0";
			ifr.style.border = "none";
			ifr.style.height = 'auto';
			ifr.style.visibility="hidden";
			ifr.allowtransparency = "true";
			this.target().appendChild(ifr);
			var iw = ifr.contentWindow.document;
			iw.open();
		}
                
                var iframeWindow = ifr.contentWindow || ifr.contentDocument.parentWindow;
                ADILoader.addEvent('load', iframeWindow, function(){
			swf.call(_this)
			
			setTimeout(function(){
			swf.call(_this);
			},3000);	
			setTimeout(function(){
				swf.call(_this);
			},6000);	
		}, this.infid, 'iframeWindow');
			

		iw.writeln(data.source);
		iw.close();
                /*tracking for network, use array tracking_url from draw reques*/
            if (data.tracking_url) {
                var tracking_url = data.tracking_url;
                var tagert_id = document.getElementById(this.id);
                if (document.getElementById(this.id + '_tr'))
                {

                } else {
                    for (var i = 0; i < tracking_url.length; i++) {
                        var tr = document.createElement('img');
                        tr.src = tracking_url[i];
                        tr.id = this.id + '_tr';
                        tr.style.display = 'none';
                        tr.style.width = '1px';
                        tr.style.height = '1px';
                        //document.body
                        tagert_id.appendChild(tr);
                    }
                }
            }		ADILoader.afterDraw(this);


    }
}
rtbLoader9862.doSwitch();