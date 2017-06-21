<%@ page language="java" import="java.util.*" pageEncoding="UTF-8"%>  
<%  
String path = request.getContextPath();  
String basePath = request.getScheme()+"://"+request.getServerName()+":"+request.getServerPort()+path+"/";  
%>  
  
<?xml version="1.0" encoding="UTF-8"?>  
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">  
<head>  
    <title>Let's Talk</title>  
    <script type="text/javascript" charset="utf-8" src="./ueditor.config.js"></script>
    <script type="text/javascript" charset="utf-8" src="./ueditor.all.js"> </script>
    <!--建议手动加在语言，避免在ie下有时因为加载语言失败导致编辑器加载失败-->
    <!--这里加载的语言文件会覆盖你在配置项目里添加的语言类型，比如你在配置项目里配置的是英文，这里加载的中文，那最后就是中文-->
    <script type="text/javascript" charset="utf-8" src="lang/zh-cn/zh-cn.js"></script>
    <style type="text/css">  
        input#chat {  
            width: 410px  
        }  
  
        #console-container {  
            width: 400px;  
        }  
  
        #console {  
            border: 1px solid #CCCCCC;  
            border-right-color: #999999;  
            border-bottom-color: #999999;  
            height: 170px;  
            overflow-y: scroll;  
            padding: 5px;  
            width: 100%;  
        }  
  
        #console p {  
            padding: 0;  
            margin: 0;  
        }  
 </style>  
    <script type="text/javascript">  
    
        var Chat = {};  
        //ue 初始化
        var ue = UE.getEditor('editor');
  
        Chat.socket = null;  
  
        Chat.connect = (function(host) {  
            if ('WebSocket' in window) {  
                Chat.socket = new WebSocket(host);  
            } else if ('MozWebSocket' in window) {  
                Chat.socket = new MozWebSocket(host);  
            } else {  
                Console.log('Error: WebSocket is not supported by this browser.');  
                return;  
            }  
  
            Chat.socket.onopen = function () {  
                Console.log('Info: WebSocket connection opened.');  
//                 document.getElementById('sendMsg').onclick = function(event) {  
//                        Chat.sendMessage();  
//                 };  
            };  
  
            Chat.socket.onclose = function () {  
                document.getElementById('sendMsg').onclick = null;  
                Console.log('Info: WebSocket closed.');  
            };  
  
            Chat.socket.onmessage = function (message) {  
                Console.log(message.data);  
            };  
        });  
  
        Chat.initialize = function() {  
            if (window.location.protocol == 'http:') {  
                Chat.connect('ws://' + window.location.host + '/webSocket/websocket/chat');  
                //Chat.connect('ws://localhost:8080/socket2/websocket/chat');  
            } else {  
                Chat.connect('wss://'+ window.location.host + '//webSocket/websocket/chat');  
                //Chat.connect('wss://localhost:8080//socket2/websocket/chat');  
            }  
        };  
  
        Chat.sendMessage = (function() {  
            var message = UE.getEditor('editor').getContent();  
            if (message != '') {  
                Chat.socket.send(message);  
                UE.getEditor('editor').setContent("");  
            }  
        });  
  
        var Console = {};  
  
        Console.log = (function(message) {  
            var console = document.getElementById('console');  
            var p = document.createElement('p');  
            p.style.wordWrap = 'break-word';  
            p.innerHTML = message;  
            console.appendChild(p);  
            while (console.childNodes.length > 25) {   
                console.removeChild(console.firstChild);  
            }  
            console.scrollTop = console.scrollHeight;  
        });  
  
        Chat.initialize();  
  
  
        document.addEventListener("DOMContentLoaded", function() {  
            // Remove elements with "noscript" class - <noscript> is not allowed in XHTML  
            var noscripts = document.getElementsByClassName("noscript");  
            for (var i = 0; i < noscripts.length; i++) {  
                noscripts[i].parentNode.removeChild(noscripts[i]);  
            }  
        }, false);  
  
	     function getContent() {
		     var arr = [];
		     arr.push("使用editor.getContent()方法可以获得编辑器的内容");
		     arr.push("内容为：");
		     arr.push(UE.getEditor('editor').getContent());
		     alert(arr.join("\n"));
	 	}
	     function ff(){
	    	 UE.getEditor('editor').execCommand( 'autosubmit');
	     }
   </script>  
</head>  
<body>
	<div class="noscript">
		<h2 style="color: #ff0000">
		Seems your browser doesn't support Javascript! Websockets rely on Javascript being enabled. Please enable  
	    Javascript and reload this page!
	    </h2>
    </div>  
	<div>  
    <div id="console-container">  
        <div id="console"/>  
    </div>
	<div id="UEDiv">
    <script id="editor" type="text/plain" style="width:800px;height:300px;"></script>  
    <br/>
    <INPUT type="button" value="发 送" id="sendMsg" onclick="ff()"/>
	</div>  
    <br/>
</div>  
</body>  
</html>  