import java.io.IOException;  
import java.util.HashMap;  
import java.util.Map;  
import java.util.concurrent.atomic.AtomicInteger;  
  
import javax.websocket.OnClose;  
import javax.websocket.OnError;  
import javax.websocket.OnMessage;  
import javax.websocket.OnOpen;  
import javax.websocket.Session;  
import javax.websocket.server.ServerEndpoint;  
  
import org.apache.juli.logging.Log;  
import org.apache.juli.logging.LogFactory;  
  
import util.HTMLFilter;   
  
/** 
 * WebSocket 消息推送服务类 
 * @author cc 
 * 
 * 2016-06-30 下午7:53:13 
 */  
@ServerEndpoint(value = "/websocket/chat")  
public class ChatAnnotation {  
  
    private static final Log log = LogFactory.getLog(ChatAnnotation.class);  
  
    private static final String GUEST_PREFIX = "Guest";  
    private static final AtomicInteger connectionIds = new AtomicInteger(0);  
    private static final Map<String,Object> connections = new HashMap<String,Object>();  
  
    private final String nickname;  
    private Session session;  
  
    public ChatAnnotation() {  
        nickname = GUEST_PREFIX + connectionIds.getAndIncrement();  
    }  
  
  
    @OnOpen  
    public void start(Session session) {  
        this.session = session;  
        connections.put(nickname, this);   
        String message = String.format("* %s %s", nickname, "has joined.");  
        broadcast(message);  
    }  
  
  
    @OnClose  
    public void end() {  
        connections.remove(nickname);  
        String message = String.format("* %s %s",  
                nickname, "has disconnected.");  
        broadcast(message);  
    }  
  
  
    /** 
     * 消息发送触发方法 
     * @param message 
     */  
    @OnMessage  
    public void incoming(String message) {  
        // Never trust the client  
        String filteredMessage = String.format("%s: %s",  
                nickname, HTMLFilter.filter(message.toString()));  
        broadcast(filteredMessage);  
    }  
  
    @OnError  
    public void onError(Throwable t) throws Throwable {  
        log.error("Chat Error: " + t.toString(), t);  
    }  
  
    /** 
     * 消息发送方法 
     * @param msg 
     */  
    private static void broadcast(String msg) {  
        if(msg.indexOf("Guest0")!=-1){  
            sendUser(msg);  
        } else{  
            sendAll(msg);
        }  
    }   
      
    /** 
     * 向所有用户发送 
     * @param msg 
     */  
    public static void sendAll(String msg){  
    	System.out.println(msg);
        for (String key : connections.keySet()) {  
            ChatAnnotation client = null ;  
            try {  
                client = (ChatAnnotation) connections.get(key); 
                String nickNameStr = client.nickname +":";
                String msgStr = msg;
                if(msgStr.indexOf(nickNameStr) >-1){
                	//msg = msg.replaceFirst(nickNameStr, "<span style=\"float:right;text-align:right;color:rgb(79,129,189);\">"+nickNameStr+"</span><br/>");
                	msgStr = "<span style=\"text-align:right;color:rgb(79,129,189);\"><p>"+msgStr+"</p></span>";
                }
            	synchronized (client) {  
            		client.session.getBasicRemote().sendText(msgStr);  
            	}  
            } catch (IOException e) {   
                log.debug("Chat Error: Failed to send message to client", e);  
                connections.remove(client);  
                try {  
                    client.session.close();  
                } catch (IOException e1) {  
                    // Ignore  
                }  
                String message = String.format("* %s %s",  
                        client.nickname, "has been disconnected.");  
                broadcast(message);  
            }  
        }  
    }  
      
    /** 
     * 向指定用户发送消息  
     * @param msg 
     */  
    public static void sendUser(String msg){  
        ChatAnnotation c = (ChatAnnotation)connections.get("Guest0");  
        try {  
            c.session.getBasicRemote().sendText(msg);  
        } catch (IOException e) {  
            log.debug("Chat Error: Failed to send message to client", e);  
            connections.remove(c);  
            try {  
                c.session.close();  
            } catch (IOException e1) {  
                // Ignore  
            }  
            String message = String.format("* %s %s",  
                    c.nickname, "has been disconnected.");  
            broadcast(message);    
        }   
    }  
}  