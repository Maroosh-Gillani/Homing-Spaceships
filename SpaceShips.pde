//declaring variables and arrays
ArrayList<ship> sh = new ArrayList<ship>();
ArrayList<missile> m = new ArrayList<missile>();
ArrayList<ball> b = new ArrayList<ball>();
ArrayList<hpBoost> h = new ArrayList<hpBoost>();

float sa, msa, ma, mma;//speed variables

button spawnMore, stopShip, move, misSpd;

void setup()
{
  sa = 0.01;
  msa = 2;
  ma = 0.2;
  mma = 5;

  size(640, 480);

  //number of ships
  for (int i = 0; i < 4; i++) sh.add(new ship(random(width), random(height)));
  //spawning chaos ball thing and hp recovery boost item
  for (int i = 0; i < 1; i++) b.add(new ball(random(width), random(height)));
  for (int i = 0; i < 1; i++) h.add(new hpBoost());

  //buttons
  spawnMore = new button(10, height - 60, 120, 50, "More Ships");
  stopShip = new button(140, height - 60, 120, 50, "Stop Ships"); 
  move = new button(270, height - 60, 120, 50, "Move Ships");
  misSpd = new button(400, height - 60, 160, 50, "+Speed Missiles");
}

void draw()
{
  if (sh.size()>1 || sh.size() == 0) background(0);//normal screen
  
  else if (sh.size() == 1)//win screen - kind of
  {
    background(190,160,0);
    fill(0);
    textSize(15);
    text("This is the strongest (or luckiest) ship. Which will eventually probably be destroyed by \nthe pink ball. Unless you add more ships.", 10, 50);
  }

  //display ships
  for (int i = 0; i < sh.size(); i++) sh.get(i).render();
  //display missiles
  for (int i = 0; i < m.size(); i++) m.get(i).render();
  //display ball
  for (int i = 0; i < b.size(); i++) b.get(i).render();
  //display hp recovery item
  for (int i = 0; i < h.size(); i++) h.get(i).render();

  //garbage collection
  for (int i = 0; i< m.size(); i++)
  {
    if (m.get(i).dead == true) m.remove(i);
  }
  for (int i = 0; i< sh.size(); i++)
  {
    if (sh.get(i).hp <= 0) sh.remove(i);
  }

  //make buttons appear
  spawnMore.render();
  stopShip.render();
  move.render();
  misSpd.render();
}

void mousePressed()
{
  if (spawnMore.mtop()) sh.add(new ship(random(width), random(height)));

  if (stopShip.mtop()) 
  {
    sa = 0;//sets ship speeds to 0, which stops the ships -- if this button is pressed when only 1 ship is left, the ship will stop when more are added
    msa = 0;
  }

  if (move.mtop()) 
  {
    sa = 0.01;//makes the ship speeds what they origianlly were; meant to act as a 'reset' in response to the stopShip button
    msa = 2;
  }

  if (misSpd.mtop())//missile button
  {
    if (mma < 15)
    {
      ma += 0.5;//increases laser speeds each time the button is clicked, but speed will only increase 10 times.
      mma += 1;
      println(ma);
    }
  }
}

class ship
{
  //declaring variables
  float x, y, sx, sy;
  int hp, cd;
  ship target;

  //assigning values
  ship(float a, float b)
  {
    this.x = a;
    this.y = b;

    this.sx = 0;
    this.sy = 0;

    this.target = null;//No value

    this.hp = 10;

    this.cd = 100;
  }

  void render()
  {
    //targetting
    while (this.target == null && sh.size() > 1)//runs as long as there isn't only 1 ship
    {
      this.target = sh.get(floor(random(sh.size())));

      if (this.target == this) this.target = null;//makes it so ship does not target itself
    }

    //unselecting dead target
    if (this.target != null)
    {
      if (this.target.hp <=0) this.target = null;//unselects when targetted ship's hp is 0 or less
    }

    //movement
    if (this.target != null)
    { 
      //homing in on the targetted ship
      if (this.x < this.target.x) this.sx += sa;
      else this.sx -= sa;

      if (this.y < this.target.y) this.sy += sa;
      else this.sy -= sa;

      //allows the ship to hit a max speed - so it does not keep accelerating
      if (this.sx > msa) this.sx = msa;
      if (this.sx < -msa) this.sx = -msa;

      if (this.sy > msa) this.sy = msa;
      if (this.sy < -msa) this.sy = -msa;
    }
    //ship x and y values increased by ship speed - allows ship to move
    this.x += this.sx;
    this.y += this.sy;

    //boundaries
    if (this.x < 0) this.x = width;
    else if (this.x > width) this.x = 0;

    if (this.y < 0) this.y = height;
    else if (this.y > height) this.y = 0;

    //draw the ship
    fill(0, 200, 200);
    ellipse(this.x, this.y, 4*this.hp, 4*this.hp);//multiplied by hp -- ships get smaller as they take damage

    //hp visual
    fill(0, 255, 0);
    text(this.hp, this.x + 15, this.y - 15);

    //target line indicator
    if (this.target != null)
    {
      stroke(255, 80);
      line(this.x, this.y, this.target.x, this.target.y);
    }

    //firing
    this.cd --;//cooldown lowers

    if (this.target != null && this.cd < 0)
    {
      for (int i = 0; i < 5; i++)//for loop allows scatter shot -- missiles fired 5 times
      {
        m.add(new missile(this.x + random(50)-25, this.y + random(50)-25, this.target));//the random allows for the scatter missiles to have distance between each other
        this.cd = 100;//resets cooldown, allowing missiles to fire again
      }
    }
  }
}

class missile
{
  //declaring variables
  float x, y, sx, sy;
  ship target;
  int fuel;
  boolean dead;

  missile(float a, float b, ship t)
  { 
    this.x = a;
    this.y = b;
    this.sx = 0;
    this.sy = 0;

    this.target = t;

    this.dead = false;

    this.fuel = 200;
  }

  void render()
  {
    //move
    if (this.target != null)
    {
      if (this.x < this.target.x) this.sx += ma;
      else this.sx -= ma;

      if (this.y < this.target.y) this.sy += ma;
      else this.sy -= ma;
      
      //implementing max speeds so the lasers don't accelerate forever
      if (this.sx > mma) this.sx = mma;
      if (this.sx < -mma) this.sx = -mma;

      if (this.sy > mma) this.sy = mma;
      if (this.sy < -mma) this.sy = -mma;
    }
    this.x += this.sx;
    this.y += this.sy;

    this.fuel--;

    //when to remove missiles
    if (this.fuel <= 0 || this.target.hp <= 0) this.dead = true;

    //collision detection
    if (this.target != null)
    {
      if (dist(this.x, this.y, this.target.x, this.target.y) < 15)//collision when distance is less than 15
      {
        this.dead = true;
        this.target.hp--;//hp lost by 1 point per hit
      }
    }

    //draw
    fill(255, 0, 0);
    ellipse(this.x, this.y, 5, 5);
  }
}

class button
{
  //declaring variables
  int x, y, w, h;
  String name;

  button(int a, int b, int c, int d, String n)
  {
    this.x = a;
    this.y = b;
    this.w = c;
    this.h = d;
    this.name = n;
  }

  void render()
  {
    //drawing
    fill(255, 50);
    rect(this.x, this.y, this.w, this.h);

    fill(0, 100, 100);
    textSize(20);

    text(this.name, this.x + this.w/2 - textWidth(this.name)/2, this.y + this.h/2 + 10);//centering text
  }

  boolean mtop()
  {
    boolean result;

    if (mouseX > this.x && mouseX < (this.x + this.w) && mouseY > this.y && mouseY < (this.y + this.h)) result = true;//true only when mouae is on top of buttons
    else result = false;

    return result;
  }
}

class ball//just a wild ball that bounces around and takes of 1 hp when it hits any of the ships
{
  float x, y, sx, sy;
  
  ball(float a, float b)
  {
    this.x = a;
    this.y = b;
    this.sx = 5;
    this.sy = 5;
  }
  
  void render()
  {
    //movement
    //makes the ball bounce
    if (this.x >= width) this.sx = -this.sx;
    else if (this.x <= 0) this.sx = -this.sx;
    
    if (this.y >= height) this.sy = -this.sy;
    else if (this.y <= 0) this.sy = -this.sy;
    
    //makes the ball actually move
    this.x += this.sx;
    this.y += this.sy;
    
    //drawing
    fill(255,150,150);
    ellipse(this.x,this.y,20,20);
    
    //collision detection
    for(int i = 0; i < sh.size(); i++)
    {
      if(sh.get(i).hp > 0 && dist(this.x, this.y, sh.get(i).x, sh.get(i).y) < 35)
      {
        sh.get(i).hp--;//takes away 1 hp from whatever ship it hit and moves to a random position to avoid taking a lot of hp in one go
        this.x = random(width);
        this.y = random(height);
      }
    }
  }
}

class hpBoost//class that handles the hp restoration block
{
  float x, y;
  hpBoost()
  {
    this.x = floor(random(width));
    this.y = floor(random(height));
  }

  void render()
  {  
    //drawing
    fill(0,255,100);
    rect(this.x,this.y,25,25);
    
    //collision detection
    for(int i = 0; i < sh.size(); i++)
    {
      if(sh.get(i).hp > 0 && dist(this.x, this.y, sh.get(i).x, sh.get(i).y) < 30)//when the distance between ship and hp block is less than 30, the stuff below happens
      {
        sh.get(i).hp+=5;//the box is teleported away so the ship does not get more than 5 hp back
        this.x = floor(random(width));
        this.y = floor(random(height));
      }
    }
  } 
}
