PImage mapImage;
Table dataTable;
int rowCount;
float dataMax[] = new float[6];
float dataMin[] = new float[6];
boolean isHover;
boolean isFront;
int mode;
String modeList[] = new String[7];
float value;
String txtValue;
int store;
int mostStore;
float percent;

void setup(){
  size(700,530);
  PFont font = createFont("ＭＳ 明朝", 24);
  textFont(font);

  mapImage=loadImage("japan.png");
  dataTable=loadTable("location.tsv");
  rowCount=dataTable.getRowCount();

  isFront=true;
  mode=0;
  modeList[0] = "都道府県内で店舗数が最も多いコンビニ";
  modeList[1] = "セブンイレブンの店舗数";
  modeList[2] = "ファミリーマートの店舗数";
  modeList[3] = "ローソンの店舗数";
  modeList[4] = "セブンイレブンの店舗数(10万人あたり)";
  modeList[5] = "ファミリーマートの店舗数(10万人あたり)";
  modeList[6] = "ローソンの店舗数(10万人あたり)";

  // 最大値と最小値を求める
  for(int row=0;row<rowCount;row++){
    float pop = dataTable.getInt(row,3)*1000;

    value = Math.round(dataTable.getInt(row,4) / (pop/100000) * 100) / 100.0;
    getMinMax(0,row,value);

    value = Math.round(dataTable.getInt(row,5) / (pop/100000) * 100) / 100.0;
    getMinMax(1,row,value);

    value = Math.round(dataTable.getInt(row,6) / (pop/100000) * 100) / 100.0;
    getMinMax(2,row,value);

    value = dataTable.getInt(row,4);
    getMinMax(3,row,value);

    value = dataTable.getInt(row,5);
    getMinMax(4,row,value);

    value = dataTable.getInt(row,6);
    getMinMax(5,row,value);
  }
}

void getMinMax(int i, int row, float value){
  if(row==0){
    dataMax[i]=value;
    dataMin[i]=value;
  }
  if(value>dataMax[i]){
    dataMax[i]=value;
  }
  if(value<dataMin[i]){
    dataMin[i]=value;
  }
}

void draw(){
  image(mapImage,0,0);
  isHover=false;

  drawCircle();
  drawValue();
}

void drawCircle(){
  if(mode==0){
    for(int row=0;row<rowCount;row++){
      int s = dataTable.getInt(row,4);
      int f = dataTable.getInt(row,5);
      int l = dataTable.getInt(row,6);
      if(s>f && s>l){
        fill(207,51,43);
      }else if(f>s && f>l){
        fill(3,151,59);
      }else{
        fill(0,118,202);
      }
      ellipse(dataTable.getInt(row,1),dataTable.getInt(row,2),10,10);
    }
  }

  if(mode==1){
    for(int row=0;row<rowCount;row++){
      if(isFront){
        value = dataTable.getInt(row,4);
        percent = norm(value,dataMin[3],dataMax[3]);
      }else{
        float pop = dataTable.getInt(row,3)*1000;
        value = Math.round(dataTable.getInt(row,4) / (pop/100000) * 100) / 100.0;
        percent= norm(value,dataMin[0],dataMax[0]);
      }
      fill(207,51,43,255*percent);
      ellipse(dataTable.getInt(row,1),dataTable.getInt(row,2),10,10);
    }

  }else if(mode==2){
    for(int row=0;row<rowCount;row++){
      if(isFront){
        value = dataTable.getInt(row,5);
        percent = norm(value,dataMin[4],dataMax[4]);
      }else{
        float pop = dataTable.getInt(row,3)*1000;
        value = Math.round(dataTable.getInt(row,5) / (pop/100000) * 100) / 100.0;
        percent= norm(value,dataMin[1],dataMax[1]);
      }
      fill(3,151,59,255*percent);
      ellipse(dataTable.getInt(row,1),dataTable.getInt(row,2),10,10);
    }
  }else if(mode==3){
    for(int row=0;row<rowCount;row++){
      if(isFront){
        value = dataTable.getInt(row,6);
        percent = norm(value,dataMin[5],dataMax[5]);
      }else{
        float pop = dataTable.getInt(row,3)*1000;
        value = Math.round(dataTable.getInt(row,6) / (pop/100000) * 100) / 100.0;
        percent= norm(value,dataMin[2],dataMax[2]);
      }
      fill(0,118,202,255*percent);
      ellipse(dataTable.getInt(row,1),dataTable.getInt(row,2),10,10);
    }
  }
}

void drawValue(){
  if(mode==0){
    fill(241,166,91);
  }else if(mode==1){
    fill(207,51,43);
  }else if(mode==2){
    fill(3,151,59);
  }else if(mode==3){
    fill(0,118,202);
  }
  if(isFront || mode==0){
    text("■"+modeList[mode],10,30);
  }else{
    text("■"+modeList[mode+3],10,30);
  }
  
  for(int row=0;row<rowCount;row++){
    int x=dataTable.getInt(row,1); 
    int y=dataTable.getInt(row,2);
    float distance=dist(x,y,mouseX,mouseY);
    float pop = dataTable.getInt(row,3)*1000;

    if(mode == 0){
      int s = dataTable.getInt(row,4);
      int f = dataTable.getInt(row,5);
      int l = dataTable.getInt(row,6);
      if(s>f && s>l){
        txtValue = "セブン";
        mostStore = s;
      }else if(f>s && f>l){
        txtValue = "ファミマ";
        mostStore = f;
      }else{
        txtValue = "ローソン";
        mostStore = l;
      }
    }else if(mode == 1){
      if(isFront){
        store = dataTable.getInt(row,4);
      }else{
        value = Math.round(dataTable.getInt(row,4) / (pop/100000) * 100) / 100.0;
      }
    }else if(mode == 2){
      if(isFront){
        store = dataTable.getInt(row,5);
      }else{
        value = Math.round(dataTable.getInt(row,5) / (pop/100000) * 100) / 100.0;
      }
    }else if(mode == 3){
      if(isFront){
        store = dataTable.getInt(row,6);
      }else{
        value = Math.round(dataTable.getInt(row,6) / (pop/100000) * 100) / 100.0;
      }
    }

    if(distance <= 5){
      isHover=true;
      fill(0,0,0);
      ellipse(dataTable.getInt(row,1),dataTable.getInt(row,2),10,10);
      
      if(mode == 0){
        fill(0,0,0,150);
        rect(x+10, y-10, 120, 25);
        fill(255,255,255);
        text(txtValue,x+20,y+10);
        fill(0,0,0);
        text(dataTable.getString(row,0)+": "+txtValue+" ("+mostStore+"軒)",10,65);
      }else{
        if(isFront){
          fill(0,0,0,150);
          rect(x+10, y-10, 120, 25);
          fill(255,255,255);
          text(store+"軒",x+20,y+10);
          fill(0,0,0);
          text(dataTable.getString(row,0)+": "+store+"軒",10,65);
        }else{
          fill(0,0,0,150);
          rect(x+10, y-10, 120, 25);
          fill(255,255,255);
          text(value+"軒",x+20,y+10);
          fill(0,0,0);
          text(dataTable.getString(row,0)+": "+value+"軒",10,65);
        }
      }
    }
  }
}

void mousePressed(){
  if(mouseButton == LEFT){
    if(mode < 3){
      mode++;
    }else{
      mode=0;
    }
  }else if(mouseButton == RIGHT && mode != 0){
    isFront=!isFront;
  }
}
