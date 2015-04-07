package
{
    import flash.display.Bitmap;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.KeyboardEvent;
    import flash.events.MouseEvent;
    import flash.text.TextField;
    import flash.text.TextFormat;
    import flash.ui.Keyboard;
    
    import net.hires.debug.Stats;
    
    import royalshield.animators.Animator;
    import royalshield.animators.utils.FrameDuration;
    import royalshield.combat.AreaCombat;
    import royalshield.core.RoyalShield;
    import royalshield.entities.creatures.Monster;
    import royalshield.entities.creatures.MonsterType;
    import royalshield.entities.creatures.NPC;
    import royalshield.entities.items.Ground;
    import royalshield.entities.items.Item;
    import royalshield.geom.Direction;
    import royalshield.geom.Position;
    import royalshield.graphics.Graphic;
    import royalshield.graphics.GraphicType;
    import royalshield.graphics.MagicEffect;
    import royalshield.graphics.Missile;
    import royalshield.graphics.Outfit;
    
    [SWF(width="800", height="600", backgroundColor="0x550088", frameRate="60")]
    public class Main extends Sprite
    {
        //--------------------------------------------------------------------------
        // PROPERTIES
        //--------------------------------------------------------------------------
        
        private var m_royalShield:RoyalShield;
        private var m_textField:TextField;
        private var m_positionTextField:TextField;
        private var m_statsTextField:TextField;
        private var oblique:Boolean = true;
        
        //--------------------------------------------------------------------------
        // CONSTRUCTOR
        //--------------------------------------------------------------------------
        
        public function Main()
        {
            if (stage)
                initialize();
            else
                addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
        }
        
        //--------------------------------------------------------------------------
        // METHODS
        //--------------------------------------------------------------------------
        
        //--------------------------------------
        // Private
        //--------------------------------------
        
        private function initialize():void
        {
            stage.scaleMode = StageScaleMode.NO_SCALE;
            stage.align = StageAlign.TOP_LEFT;
            
            m_royalShield = new RoyalShield();
            m_royalShield.display.x = 75;
            m_royalShield.display.scale = 1.5;
            m_royalShield.display.addEventListener(MouseEvent.CLICK, gameDisplayMouseClickHandler);
            m_royalShield.world.map.onPositionChanged.add(mapPositionChanged);
            addChild(m_royalShield.display);
            
            m_textField = new TextField();
            m_textField.width = 300;
            m_textField.defaultTextFormat = new TextFormat("Arial", 12, 0xFFFFFF, true);
            m_textField.x = m_royalShield.display.x;
            m_textField.y = m_royalShield.display.y + m_royalShield.display.height + 10;
            m_textField.text = "X: magic effect\n" +
                               "C: magic effect area\n" +
                               "V: missile effect\n" +
                               "G: grid\n" +
                               "Page Up: level +\n" +
                               "Page Down: level -\n" +
                               "SPACE: change tileset";
            addChild(m_textField);
            
            m_positionTextField = new TextField();
            m_positionTextField.width = 150;
            m_positionTextField.height = 20;
            m_positionTextField.defaultTextFormat = new TextFormat("Arial", 12, 0xFFFFFF, true);
            m_positionTextField.x = m_royalShield.display.width - m_positionTextField.width;
            m_positionTextField.y = m_royalShield.display.y + m_royalShield.display.height + 10;
            addChild(m_positionTextField);
            
            m_statsTextField = new TextField();
            m_statsTextField.width = 150;
            m_statsTextField.height = 20;
            m_statsTextField.x = m_positionTextField.x;
            m_statsTextField.y = m_positionTextField.y + m_positionTextField.height + 10;
            m_statsTextField.defaultTextFormat = new TextFormat("Arial", 12, 0xFFFFFF, true);
            m_statsTextField.text = "Level: 1";
            addChild(m_statsTextField);
            
            addChild(new Stats());
            
            test1();
            
            // TODO: temporary way to get a loop.
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
            stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
        }
        
        public function test1():void
        {
            m_royalShield.world.clear();
            m_royalShield.player.destroy();
            
            // Adds the ground
            
            var type:GraphicType = new GraphicType();
            type.patternX = 4;
            type.patternY = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new GROUND_TEXTURE).bitmapData);
            
            var ground:Ground = new Ground(0, "ground", 100);
            ground.graphic = new Graphic(type);
            
            for (var x:uint = 0; x <= 50; x++) {
                for (var y:uint = 0; y <= 50; y++) {
                    m_royalShield.world.map.setTile(x, y, 0);
                    m_royalShield.world.addItem(ground, x, y, 0);
                }
            }
            
            // Adds the tree
            
            type = new GraphicType();
            type.width = 3;
            type.height = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new TREE_TEXTURE).bitmapData);
            
            var tree:Item = new Item(0, "tree");
            tree.solidMap = Vector.<uint>([1]);
            tree.solidMapColumns = 1;
            tree.graphic = new Graphic(type);
            m_royalShield.world.addItem(tree, 10, 10, 0);
            m_royalShield.world.addItem(tree, 15, 15, 0);
            m_royalShield.world.addItem(tree, 16, 17, 0);
            m_royalShield.world.addItem(tree, 16, 12, 0);
            m_royalShield.world.addItem(tree, 10, 17, 0);
            
            // Adds the stone
            
            type = new GraphicType();
            type.width = 2;
            type.height = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new STONE_TEXTURE).bitmapData);
            
            var stone:Item = new Item(0, "stone");
            stone.solidMap = Vector.<uint>([1, 1]);
            stone.solidMapColumns = 1;
            stone.graphic = new Graphic(type);
            m_royalShield.world.addItem(stone, 17, 14, 0);
            
            // Adds the camp fire
            
            var durations:Vector.<FrameDuration> = new Vector.<FrameDuration>(5, true);
            durations[0] = new FrameDuration(80, 180);
            durations[1] = new FrameDuration(80, 100);
            durations[2] = new FrameDuration(100, 180);
            durations[3] = new FrameDuration(80, 180);
            durations[4] = new FrameDuration(80, 120);
            var animator:Animator = new Animator(durations.length, 0, 0, durations);
            
            type = new GraphicType();
            type.width = 1;
            type.height = 2;
            type.frames = durations.length;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new CAMP_FIRE).bitmapData);
            type.animator = animator;
            
            var campFire:Item = new Item(0, "camp fire");
            campFire.graphic = new Graphic(type);
            m_royalShield.world.addItem(campFire, 28, 14, 0);
            
            // Adds the player
            
            type = new GraphicType();
            type.width = 1;
            type.height = 1;
            type.patternX = 4;
            type.frames = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new OUTFIT_TEXTURE).bitmapData);
            
            var outfit:Outfit = new Outfit(type);
            m_royalShield.player.outfit = outfit;
            m_royalShield.player.onWalkCompleted.add(playerWalkComplete);
            m_royalShield.player.onLevelChanged.add(playerLavelChanged);
            m_royalShield.world.addCreature(m_royalShield.player, 19, 14, 0);
            
            // Adds a NPC
            
            var npc:NPC = new NPC("Npc");
            npc.outfit = new Outfit(type);
            if (m_royalShield.world.addCreature(npc, 12, 14, 0))
                npc.setCreatureFocus(m_royalShield.player);
            
            // Adds a Monster
            var monsterType:MonsterType = new MonsterType();
            monsterType.name = "Monster";
            var monster:Monster = new Monster(monsterType);
            monster.outfit = new Outfit(type);
            m_royalShield.world.addCreature(monster, 20, 25, 0);
        }
        
        public function test2():void
        {
            m_royalShield.world.clear();
            m_royalShield.player.destroy();
            
            // Adds the ground
            
            var type:GraphicType = new GraphicType();
            type.patternX = 2;
            type.patternY = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new GROUND_TEXTURE2).bitmapData);
            
            var ground:Ground = new Ground(0, "ground", 100);
            ground.graphic = new Graphic(type);
            
            for (var x:uint = 0; x <= 50; x++) {
                for (var y:uint = 0; y <= 50; y++) {
                    m_royalShield.world.map.setTile(x, y, 0);
                    m_royalShield.world.addItem(ground, x, y, 0);
                }
            }
            
            // Adds the tree
            
            type = new GraphicType();
            type.height = 2;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new TREE_TEXTURE2).bitmapData);
            
            var tree:Item = new Item(0, "tree");
            tree.solidMap = Vector.<uint>([1]);
            tree.solidMapColumns = 1;
            tree.graphic = new Graphic(type);
            for (var i:uint = 0; i < 150; i++)
                m_royalShield.world.addItem(tree, Math.random() * 50, Math.random() * 50, 0);
            
            // Adds the bush
            
            type = new GraphicType();
            type.patternX = 2;
            type.patternY = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new BUSH).bitmapData);
            
            var bush:Item = new Item(0, "bush");
            bush.graphic = new Graphic(type);
            for (i = 0; i < 200; i++)
                m_royalShield.world.addItem(bush, Math.random() * 50, Math.random() * 50, 0);
            
            // Adds the player
            
            type = new GraphicType();
            type.patternX = 4;
            type.frames = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new OUTFIT_TEXTURE2).bitmapData);
            
            var outfit:Outfit = new Outfit(type);
            m_royalShield.player.outfit = outfit;
            m_royalShield.player.onWalkCompleted.add(playerWalkComplete);
            m_royalShield.player.onLevelChanged.add(playerLavelChanged);
            m_royalShield.world.addCreature(m_royalShield.player, 19, 14, 0);
        }
        
        //--------------------------------------
        // Private
        //--------------------------------------
        
        private function createMagicEffet():MagicEffect
        {
            var durations:Vector.<FrameDuration> = new Vector.<FrameDuration>(8, true);
            for (var i:uint = 0; i < durations.length; i++)
                durations[i] = new FrameDuration(100, 100);
            
            var animator:Animator = new Animator(durations.length, 1, 0, durations);
            var type:GraphicType = new GraphicType();
            type.width = 1;
            type.height = 1;
            type.frames = durations.length;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new ME_EXPLOSION).bitmapData);
            type.animator = animator;
            return new MagicEffect(type);
        }
        
        private function testMagicEffect():void
        {
            var effect:MagicEffect = createMagicEffet();
            m_royalShield.world.addEffect(effect, m_royalShield.player.tile.x, m_royalShield.player.tile.y, m_royalShield.player.tile.z);
        }
        
        private function testArea():void
        {
            var area:AreaCombat = new AreaCombat();
            area.setupAreaByRadius(5); // sets the effect area
            
            var center:Position = new Position();
            center.x = m_royalShield.player.tile.x;
            center.y = m_royalShield.player.tile.y;
            center.z = m_royalShield.player.tile.z;
            var target:Position = center.clone();
            var positions:Vector.<Position> = new Vector.<Position>();
            if (area.getList(center, target, positions)) {
                for (var i:uint = 0; i < positions.length; i++) {
                    var effect:MagicEffect = createMagicEffet();
                    var pos:Position = positions[i];
                    m_royalShield.world.addEffect(effect, pos.x, pos.y, pos.z);
                }
            }
        }
        
        private function testMissile():void
        {
            var type:GraphicType = new GraphicType();
            type.patternX = 3;
            type.patternY = 3;
            type.spriteSheet = m_royalShield.assets.getSpriteSheet(type, Bitmap(new MISSILE_TEXTURE).bitmapData);
            
            var x:uint = m_royalShield.player.tile.x;
            var y:uint = m_royalShield.player.tile.y;
            var z:uint = m_royalShield.player.tile.z;
            
            var positions:Array = [];
            positions[positions.length] = {x:-5, y:-5}
            positions[positions.length] = {x:5, y:-5}
            positions[positions.length] = {x:-5, y:5}
            positions[positions.length] = {x:5, y:5}
            positions[positions.length] = {x:0, y:-5}
            positions[positions.length] = {x:5, y:0}
            positions[positions.length] = {x:-5, y:0}
            positions[positions.length] = {x:0, y:5}
                
            for (var i:uint = 0; i < positions.length; i++) {
                var missile:Missile = new Missile(type, x, y, x + positions[i].x, y + positions[i].y);
                m_royalShield.world.addEffect(missile, x, y, z);
            }
        }
        
        private function playerWalkComplete():void
        {
            //trace("Main.playerWalkComplete()");
        }
        
        private function playerLavelChanged(oldLevel:uint, newLevel):void
        {
            m_statsTextField.text = "Level: " + newLevel;
        }
        
        private function mapPositionChanged(x:uint, y:uint, z:uint):void
        {
            m_positionTextField.text = "Position: x="+x+", y="+y+", z="+z;
        }
        
        //--------------------------------------
        // Event Handlers
        //--------------------------------------
        
        protected function addedToStageHandler(event:Event):void
        {
            removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
            initialize();
        }
        
        protected function enterFrameHandler(event:Event):void
        {
            m_royalShield.update();
        }
        
        protected function keyDownHandler(event:KeyboardEvent):void
        {
            var code:uint = event.keyCode;
            switch(code)
            {
                case Keyboard.UP:
                    m_royalShield.movePlayer(Direction.NORTH);
                    break;
                
                case Keyboard.DOWN:
                    m_royalShield.movePlayer(Direction.SOUTH);
                    break;
                
                case Keyboard.LEFT:
                    m_royalShield.movePlayer(Direction.WEST);
                    break;
                
                case Keyboard.RIGHT:
                    m_royalShield.movePlayer(Direction.EAST);
                    break;
                
                case Keyboard.G:
                    m_royalShield.display.showGrid = !m_royalShield.display.showGrid;
                    break;
                
                case Keyboard.X:
                    testMagicEffect();
                    break;
                
                case Keyboard.C:
                    testArea();
                    break;
                
                case Keyboard.V:
                    testMissile();
                    break;
                
                case Keyboard.T:
                    m_royalShield.player.stopWalk();
                    break;
                
                case Keyboard.PAGE_UP:
                    m_royalShield.player.level = Math.min(m_royalShield.player.level + 1, 800);
                    break;
                
                case Keyboard.PAGE_DOWN:
                    m_royalShield.player.level = Math.max(m_royalShield.player.level - 1, 0);
                    break;
                
                case Keyboard.SPACE:
                    oblique = !oblique;
                    if (oblique)
                        test1();
                    else
                        test2();
                    break;
            }
        }
        
        protected function gameDisplayMouseClickHandler(event:MouseEvent):void
        {
            var position:Position = m_royalShield.display.pointToPosition(event.localX, event.localY);
            if (position)
                m_royalShield.moveCreatureToPosition(m_royalShield.player, position);
        }
        
        //--------------------------------------------------------------------------
        // STATIC
        //--------------------------------------------------------------------------
        
        // TODO: temporary textures
        [Embed(source="../assets/ground.png", mimeType="image/png")]
        public static const GROUND_TEXTURE:Class;
        
        [Embed(source="../assets/ground2.png", mimeType="image/png")]
        public static const GROUND_TEXTURE2:Class;
        
        [Embed(source="../assets/tree.png", mimeType="image/png")]
        public static const TREE_TEXTURE:Class;
        
        [Embed(source="../assets/tree2.png", mimeType="image/png")]
        public static const TREE_TEXTURE2:Class;
        
        [Embed(source="../assets/stone.png", mimeType="image/png")]
        public static const STONE_TEXTURE:Class;
        
        [Embed(source="../assets/outfit.png", mimeType="image/png")]
        public static const OUTFIT_TEXTURE:Class;
        
        [Embed(source="../assets/outfit2.png", mimeType="image/png")]
        public static const OUTFIT_TEXTURE2:Class;
        
        [Embed(source="../assets/camp_fire.png", mimeType="image/png")]
        public static const CAMP_FIRE:Class;
        
        [Embed(source="../assets/explosion.png", mimeType="image/png")]
        public static const ME_EXPLOSION:Class;
        
        [Embed(source="../assets/missile.png", mimeType="image/png")]
        public static const MISSILE_TEXTURE:Class;
        
        [Embed(source="../assets/bush.png", mimeType="image/png")]
        public static const BUSH:Class;
    }
}
