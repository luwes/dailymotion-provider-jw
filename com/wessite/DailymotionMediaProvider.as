package com.wessite {
	
	import flash.display.*;
	import flash.events.*;
	import flash.net.URLRequest;
	import flash.system.Security;

	import com.longtailvideo.jwplayer.events.MediaEvent;
	import com.longtailvideo.jwplayer.media.MediaProvider;
	import com.longtailvideo.jwplayer.model.PlayerConfig;
	import com.longtailvideo.jwplayer.model.PlaylistItem;
	import com.longtailvideo.jwplayer.player.PlayerState;
	import com.longtailvideo.jwplayer.plugins.IPlugin;
	import com.longtailvideo.jwplayer.utils.*;

	public class DailymotionMediaProvider extends MediaProvider {
		
		
		private var loader:Loader;
		public var back:Sprite;
		public var player:Object;
		
		private var playerReady:Boolean = false;
		private var startItem:PlaylistItem;
		
		
		public function DailymotionMediaProvider() {
			super("dailymotion");
        	Security.allowDomain("www.dailymotion.com");
		}
		
		override public function initializeMediaProvider(cfg:PlayerConfig):void {
			super.initializeMediaProvider(cfg);

			var components:MovieClip = (RootReference.stage.getChildAt(0) as MovieClip).getChildByName("components") as MovieClip;
			back = new Sprite();
			components.addChildAt(back, 1);

			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, onLoaderInit);
            loader.load(new URLRequest("http://www.dailymotion.com/swf?enableApi=1&chromeless=1"));
		}
		
		private function errorHandler(e:ErrorEvent):void {
			error(e.text);
		}
		
		public function onLoaderInit(e:Event):void {
			player = loader.content;
			back.addChild(loader);
			//media = loader;
			sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_LOADED);

			player.stage.addEventListener(Event.RESIZE, resizeHandler);
			
            player.addEventListener("onReady", onReady);
			player.addEventListener("onError", onError);
			player.addEventListener("onStateChange", onStateChange);
			player.addEventListener("onVideoBufferFull", onVideoBufferFull);
			player.addEventListener("onVideoProgress", onVideoProgress);
			player.addEventListener("onLinearAdStart", onLinearAdStart);
        }
        
		public function onReady(e:Event):void {
			//trace("player ready:", Object(e).data.playerId);
			playerReady = true;
			resizeHandler(null);
			if (startItem) {
				load(startItem);
			}
        }

        public function onError(e:Event):void {
            // Event.data contains the event parameter, which is the error code
            error(Object(e).data);
        }

        public function onStateChange(e:Event):void {
        	back.visible = true;
            var stt:int = Object(e).data;
			switch (stt) {
				case 0:
					if (state != PlayerState.IDLE) {
						setState(PlayerState.IDLE);
						_position = 0;
						sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_COMPLETE);
						player.clearVideo();
						back.visible = false;
					}
					break;
				case 1:
					super.play();
					break;
				case 2:
					super.pause();
					break;
				case 3:
					setState(PlayerState.BUFFERING);
					break;
			}
        }
        
        public function onVideoBufferFull(e:Event):void {
        	if (position == 0) {
        		sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_BUFFER_FULL);
        	}
        }
        
        public function onVideoProgress(e:Event):void {
        	var data:Object = Object(e).data;

			if (_item.duration <= 0) {
				_item.duration = player.getDuration();
			}

			sendBufferEvent(100 * (data.mediaBytesReceived / data.mediaBytesTotal), 0, { loaded: data.mediaBytesReceived, total: data.mediaBytesTotal });
			
			if (state == PlayerState.PLAYING) {
				
				_position = data.mediaTime;

				sendMediaEvent(MediaEvent.JWPLAYER_MEDIA_TIME, {position: position, duration: item.duration});
			}
        }
        
        private function onLinearAdStart(e:Event):void {
        	super.play();
        }
        
		public static function getID(url:String):String {
			var str:String = url;
			
			var result:Array = url.match(/video\/([^_\/]+)/i);
			if (result) str = result[1];

			return str;
		}
		
		override public function load(itm:PlaylistItem):void {
			if (playerReady) {
				_position = 0;
				
				player.loadVideoById(getID(itm.file));
				super.load(itm);
				
				setState(PlayerState.BUFFERING);
				sendBufferEvent(0);
			} else {
				startItem = itm;
			}
		}
		
		override public function pause():void {
			player.pauseVideo();
			super.pause();
		}
		
		override public function play():void {
			player.playVideo();
			super.play();
		}

		override public function seek(pos:Number):void {
			player.seekTo(pos);
			super.seek(pos);
		}

		override public function setVolume(vol:Number):void {
			player.setVolume(vol);
			super.setVolume(vol);
		}
		
		public function resizeHandler(e:Event):void {
			if (playerReady) {
				player.setSize(config.width, config.height);
			}
		}
	}	
}