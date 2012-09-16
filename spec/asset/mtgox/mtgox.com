<!DOCTYPE html>
<!--[if lt IE 7 ]> <html itemscope itemtype="http://schema.org/Organization" class="ie ie6"> <![endif]-->
<!--[if IE 7 ]>    <html itemscope itemtype="http://schema.org/Organization" class="ie ie7"> <![endif]-->
<!--[if IE 8 ]>    <html itemscope itemtype="http://schema.org/Organization" class="ie ie8"> <![endif]-->
<!--[if IE 9 ]>    <html itemscope itemtype="http://schema.org/Organization" class="ie ie9"> <![endif]-->
<!--[if gt IE 9]><!--><html itemscope itemtype="http://schema.org/Organization"><!--<![endif]-->
    <head>
    <title>Mt.Gox - Bitcoin Exchange </title>
    <meta http-equiv="content-type" value="text/html; charset=UTF-8"/>
    <meta name="title" content="Mt.Gox - Bitcoin Exchange " />
    <meta name="description" content="[color=#404040]bitcoins, bitcoin, buying bitcoin, alternative currency, decentralized currency, e-currency, tradehill, trade hill, cryptoxchange, online currency, money, bit coin, cryptocurrency, crypto-currency, bitcointalk, bitcoin talk, tibanne[/color]" />

    <link href="/favicon.ico" title="Icon" type="image/x-icon" rel="icon" /> 
    <link href="/favicon.ico" title="Icon" type="image/x-icon" rel="shortcut icon" />

    <meta name="author" content="Tibanne" />

    <meta name="Copyright" content="Copyright Tibanne 2011. All Rights Reserved." />

    <meta name="DC.title" content="Mt.Gox - Bitcoin Exchange " />
    <meta name="DC.subject" content="bitcoins, bitcoin, buying bitcoin, alternative currency, decentralized currency, e-currency, tradehill, trade hill, cryptoxchange, online currency, money, bit coin, cryptocurrency, crypto-currency, bitcointalk, bitcoin talk, tibanne" />
    <meta name="DC.creator" content="Tibanne" />
    <meta name="keywords" content="[color=#404040]bitcoins, bitcoin, buying bitcoin, alternative currency, decentralized currency, e-currency, tradehill, trade hill, cryptoxchange, online currency, money, bit coin, cryptocurrency, crypto-currency, bitcointalk, bitcoin talk, tibanne[/color]">

    <meta name="viewport" content="width=device-width, initial-scale=.9" />
    <meta name="robots" content="index, follow" />
    <meta name="format-detection" content="telephone=no">

    <link rel="shortcut icon" href="/favicon.ico" />
  <!-- Included: Font Awesome - http://fortawesome.github.com/Font-Awesome -->
    <link rel="stylesheet" type="text/css" href="/_minify/9a0f60162bfc696f6a15759cf89720823f8f4f2c.css">
    <!--[if IE]> <link rel="stylesheet" type="text/css" href="/_minify/4fc24e00be0f7f25acbb96908dc030c9b38c9198.css"> <![endif]-->
    <!--[if lt IE 7 ]> <link rel="stylesheet" type="text/css" href="/_minify/7b922b0c59b24fa22559c78c77aead4ed39421a1.css"> <![endif]-->
    <!--[if IE 7 ]> <link rel="stylesheet" type="text/css" href="/_minify/2ccb10e8d525f5973d64f11e83e007c3a9ecbe3e.css"> <![endif]-->
    <script type="text/javascript">
        var wsURL = 'https://socketio.mtgox.com/mtgox?Channel=ticker&Currency=USD&IdKey=HNxJ7x1CSTGOqPYSa5SL3QAAAABQVobTqOnFgqoAwhHdxZewwuOEhrM+YZnCXThY6kzFi5xttB4';
        var token = "92H4J8GTWFE5UEPY2L4V2WRN996JDMNP";
        var isMarketOrder = false;
    </script>

    <script type="text/javascript" src="/_minify/7015d27ac59f3a37f8aed0137f1989b98b51ef3c.js"></script>

    <!-- Update your html tag to include the itemscope and itemtype attributes -->
    <!-- html itemscope itemtype="http://schema.org/Organization" -->

    <!-- Add the following three tags inside head -->
    <meta itemprop="name" content="MtGox">
    <meta itemprop="description" content="[color=#404040]bitcoins, bitcoin, buying bitcoin, alternative currency, decentralized currency, e-currency, tradehill, trade hill, cryptoxchange, online currency, money, bit coin, cryptocurrency, crypto-currency, bitcointalk, bitcoin talk, tibanne[/color]">
    <meta itemprop="image" content="https://mtgox.com/img/mtgox_large.jpg">

    <script type="text/javascript">
<!--
var _gaq = _gaq || [];
_gaq.push(['_setAccount', "UA-12152097-26"]);
_gaq.push(['_trackPageview']);
var track = track || false;
track = { ev: function() { var t = new Array(); for(i = 0; i < arguments.length; i++) t.push(arguments[i]); t.unshift("_trackEvent"); _gaq.push(t); if (this.parent) { t.shift(); this.parent.ev.apply(this.parent, t); } }, parent: track };
(function() {
  var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
  ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
  (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(ga);
})();

// --></script>

  <!-- Google Website Optimizer Control Script -->
    <script type="text/javascript">
    function utmx_section(){}function utmx(){}
    (function(){var k='2602882825',d=document,l=d.location,c=d.cookie;function f(n){
    if(c){var i=c.indexOf(n+'=');if(i>-1){var j=c.indexOf(';',i);return escape(c.substring(i+n.
    length+1,j<0?c.length:j))}}}var x=f('__utmx'),xx=f('__utmxx'),h=l.hash;
    d.write('<sc'+'ript src="'+
    'http'+(l.protocol=='https:'?'s://ssl':'://www')+'.google-analytics.com'
    +'/siteopt.js?v=1&utmxkey='+k+'&utmx='+(x?x:'')+'&utmxx='+(xx?xx:'')+'&utmxtime='
    +new Date().valueOf()+(h?'&utmxhash='+escape(h.substr(1)):'')+
    '" type="text/javascript" charset="utf-8"></sc'+'ript>')})();
    </script>
    <!-- End of Google Website Optimizer Control Script -->
</head>
    
    <body class="trade">
     
      <script>
      var userID=4699; 
      </script>
    
                
        <div id="blind">

    <div class="bigchart">
        <div id="bigchartBar">
        <a href="http://www.mtgoxlive.com" target="_blank">MtGoxLive graph</a>
      </div>
        <div id="bigchartHolder"></div>
    </div>

    <div class="handle ticker">
     <div class="SupportHelpHolder"><a href="https://support.mtgox.com/forums" class="icons iconSupportHelp">Support</a></div>
     <div id="dataHolder">
          <ul>
              <li id="smallChart"><a href="#" title="Click to see the chart!" id="handleBtn" class="icons iconGraph">Show chart</a></li> 
              <li id="lastPrice">Last price:<span>$11.88500</span></li> 
              <li id="highPrice">High:<span>$11.90000</span></li> 
              <li id="lowPrice">Low:<span>$11.60000</span></li> 
              <li id="volume">Volume:<span>21589 BTC</span></li> 
              <li id="weightedAverage">Weighted Avg:<span>$11.77275</span></li> 
          </ul>
     </div>
    
    
    </div>

</div>
        
        <div class="wrapper">
            
            <header>
    <a href="/" title="Mt. Gox" class="icons" id="mtGoxLogo">Mt. Gox</a>


    <section>
    <div id="userBar">
          <ul class="bar barUser">
              <li><span>Account Number: 4699</span></li>
              <li><a href="/trade#open-orders" class="openOrder">&nbsp;<span class="icons iconOpenOrder">&nbsp;</span>Open orders: <span id="openOrders">0</span></a></li>
          </ul>
          <ul class="bar barUser">
              <li><a href="/settings/" class="user">&nbsp;<span class="icons iconUser">&nbsp;</span>tourbillon</a></li>
              <li><a href="/logout/" class="logout"><span class="icons iconLogout">&nbsp;</span>Sign out</a></li>
          </ul>
     </div>

        <ul id="walletBar" class="bar">
            <li>Your wallet:</li>
            <li id="virtualCur">
                <strong>
                    <span class="amount">25.03500000 BTC</span>
                </strong>
            </li>
      
        <li>
          <span class="selected USD">
                    <span class="currency flags" style="background-image: url(https://mtgox.com/common/img/flags/us.png);"> P </span>
                    <span class="amount">$22.01601</span>
                </span>
        </li>
      
        </ul>
    </section>


</header>
            
            <nav class="mainNav rounded7 roundedBottomOnly line">
    <ul class="unit">
        <li><a href="/" title="Home">&nbsp;<span class="icons iconHome"> </span>Home</a></li>
        
    </ul>
    <ul class="lastUnit">
        <li>
      &nbsp;<a href="#" id="supportChat" class="icon-comments-alt logos">Chat</a>
            &nbsp;<a href="http://www.facebook.com/MtGox" target="_blank" title="Facebook" class="logos icons iconFb">Facebook</a>
        <a class="g-plusone" href="https://plus.google.com/100448119000434100275" target="_blank"></a>
        </li>
        <li><a href="https://support.mtgox.com/forums/20105883-faq" title="FAQ">FAQ</a></li>
        <li><a href="/settings/" title="Settings">Settings</a></li>
        <li><a href="https://mtgox.com/security/" title="Security Center">Security Center</a></li>
        
        <li><a href="/merchant/" title="Merchant Tools">Merchant Tools</a></li>
        <li><a href="/trade/" title="Trade">Trade</a></li>
    </ul>
</nav>






  

            
            
            <script>
                $(document).ready(function(){
                    tb.tabify();
                });
            </script>
            <div class="line">
                
                <div class="title line">
                    <h1 class="unit">Buy &amp; Sell</h1>
                </div>
                
                <div class="colLeft unit">
                
                    <nav>
  <ul>
    <li><span class="active">Trade</span></li>
    <li><a href="/trade/funding-options" title="Funding Options">Funding Options</a></li>
    <li><a href="/trade/account-history?currency=BTC" title="Account history">Account history</a></li>
    <li><a href="/merchant/checkout">Checkout button</a></li>
  </ul>
</nav>
<figure class="bottomPicto"><img src="/img/left_col_trade_picto.jpg" alt="" /></figure>
                    
                </div>
                
                <div class="colRight lastUnit size1of3">
                    
                   <script type="text/javascript" src="/_minify/b938ea1ea9953c32bd1107cbd32d66749ce3a85a.js"></script>
<link rel="stylesheet" type="text/css" href="/css/jquery.dataTables.css" />

<script type="text/javascript" language="javascript">
  var token = "92H4J8GTWFE5UEPY2L4V2WRN996JDMNP";
  $(document).ready(function(){
    $('.popup').popover(popupOptions);
    
    popupOptions.placement = 'above';
    $('.popupAbove').popover(popupOptions);
  });
</script>


            <div id="status" class="success"></div>
            <div id="error" class="error"></div>
            
            
            
            <section id="tradeManager" class="tableTabs tabify ">
                            
                            <div id="btcTradeVolumeBar" class="popupAbove" data-content=" Mt Gox charges a small fee (0.6 %) for each trade.

Your trading volume for the past 30 days is 0.00000000 BTC. If it reaches 100.00000000 BTC, your nominal trading fee will be 0.55%.

 " data-original-title="Volume Discount Display">
                                <span class="indicator">0%</span>
                                <div class="progressBarWrapper">
                                    <span class="progressStart">0.6%</span>
                                    <span class="progressEnd">0.55%</span>
                                    <div class="progressBar" style="width:1%;"></div>
                                </div>
                            </div>
                            
                            
  <span class="icons iconLongFormOn placeRight">&nbsp;</span>
   <a href="/trade?meta[MtGox_Trade_Display]=compact&amp;meta[once]=92H4J8GTWFE5UEPY2L4V2WRN996JDMNP" class="icons iconCompactOff placeRight">&nbsp;</a>

                            <ul class="tabs">
                                <li><a href="#buy" class="active">Buy bitcoins</a></li>
                                <li><a href="#sell">Sell bitcoins</a></li>
                            </ul>

                  <form method="get" style="margin:10px;">
                      <input type="checkbox" name="marketOrderCheck" id="marketOrderCheck" /> <label for="marketOrderCheck">Market Order (buy/sell at market price)</label>
                  </form>

                            <form class="tableContent" action="" id="buyForm">
                                <a name="buy"></a>

                                <input type="hidden" name="token" id="token" value="92H4J8GTWFE5UEPY2L4V2WRN996JDMNP"/>
                                
                                <table class="verticalShadow">
                                    <tr>
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="&quot;Lowest Ask Price&quot; is the cheapest you are likely to buy bitcoins for if you wish to purchase them now" data-original-title="Lowest Ask Price" class="icon-question-sign iconHelp"></a></td>
                                        <td class="secondCol">
                                            <p>USD in your account</p>
                                            <p>Lowest Ask Price</p>
                                        </td>
                                        <td class="thirdCol">
                                            <p>
                                                <span class="funds">$22.01601</span> (<a href="/trade/funding-options">add more</a>)
                                            </p>
                                            <p id="buyP">$11.88500</p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="&quot;Amount to buy&quot; is the quantity of bitcoins you want to buy from a seller" data-original-title="Amount to buy" class="icon-question-sign iconHelp"></a></td>
                                        <td>
                                            <p>Amount of BTC to BUY</p>
                                        </td>
                                        <td>
                                            <input type="text" tabindex="1" value="" placeholder="Enter amount" name="buyAmount" id="buyAmount" />
                                        </td>
                                    </tr>
                                    <tr class="marketToHide">
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="&quot;Price per coin in USD&quot; is the price you wish to purchase your bitcoins at" data-original-title="&quot;Price per coin in USD&quot;" class="icon-question-sign iconHelp"></a></td>
                                        <td>
                                            <p>Price per coin in USD</p>
                                        </td>
                                        <td>
                                            <input type="text" tabindex="2" value="11.885" placeholder="Enter amount" name="buyPrice" id="buyPrice" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="For a simpler way to calculate the &quot;Amount to buy/sell&quot; you can enter in the total value, the price you would like to buy/sell at, and the amount will be caclulated for you." data-original-title="Order Total" class="icon-question-sign iconHelp"></a></td>
                                        <td>
                                            <p>Total to spend in USD</p>
                                        </td>
                                        <td class="total">
                                            <p><input type="text" tabindex="3" name="buyCost" id="buyCost" value="0" /></p>
                                        </td>
                                    </tr>
                                </table>
                                

                                        <div id="buyError" class="error"></div>
                                        <div id="buyStatus" class="success"></div>

                                <p class="block bigSpace centered">
                                    <a href="#" class="submitBtn button buttonLongest popup" title="Buy bitcoins" data-content="You can make a lower offer but it won't be filled until someone accepts it."><span>Buy bitcoins</span></a>
                                </p>

                            </form>

                            <form class="tableContent" id="sellForm" action="">
                                <a name="sell"></a>

                                
                                <table class="verticalShadow">
                                    <tr>
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="&quot;Highest Bid Price&quot; is the highest your are likely able to sell your bitcoins for if you want to sell them now" data-original-title="Highest Bid Price" class="icon-question-sign iconHelp"></a></td>
                                        <td class="secondCol">
                                            <p>Bitcoins in your account</p>
                                            <p>Highest Bid Price</p>
                                        </td>
                                        <td class="thirdCol">
                                            <p>
                                                <span class="funds">25.035</span> (<a href="/trade/funding-options">add more</a>)
                                            </p>
                                            <p id="sellP">$11.83100</p>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="&quot;Amount to sell&quot; is the quantity of bitcoins you wish to sell to a buyer" data-original-title="Amount to sell" class="icon-question-sign iconHelp"></a></td>
                                        <td>
                                            <p>Amount of BTC to SELL</p>
                                        </td>
                                        <td>
                                            <input type="text" tabindex="4" value="" placeholder="Enter amount" name="sellAmount" id="sellAmount" />
                                        </td>
                                    </tr>
                                    <tr class="marketToHide">
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="&quot;Price per coin in &quot; is the price you wish to purchase your bitcoins at" data-original-title="&quot;Price per coin in &quot;" class="icon-question-sign iconHelp"></a></td>
                                        <td>
                                            <p>Price per coin in USD</p>
                                        </td>
                                        <td>
                                            <input type="text" tabindex="5" value="11.831" placeholder="Enter amount" name="sellPrice" id="sellPrice" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td class="firstCol">&nbsp;<a href="#" title="" data-content="For a simpler way to calculate the &quot;Amount to buy/sell&quot; you can enter in the total value, the price you would like to buy/sell at, and the amount will be caclulated for you." data-original-title="Order Total" class="icon-question-sign iconHelp"></a></td>
                                        </td>
                                        <td>
                                            <p>Amount to receive in USD</p>
                                        </td>
                                        <td class="total">
                                            <p><input type="text" tabindex="6" name="sellCost" id="sellCost" value="0" /></p>
                                        </td>
                                    </tr>
                                </table>
                                

                                <div id="sellError" class="error"></div>
                                <div id="sellStatus" class="success"></div>

                                <p class="block bigSpace centered">
                                    <a href="#" class="submitBtn button buttonLongest buttonBlue popup" title="Sell Bitcoins" data-content="You can make a higher offer but it won't be filled until someone accepts it."><span>Sell Bitcoins</span></a>
                                </p>

                            </form>

                        </section>

                        <form class="tableTabs">

                            <span class="icons iconBook placeRight">&nbsp;</span>
                            <ul class="tabs">              
                                <li><h3>Your Open Orders</h3><a name="open-orders" style="visibility:hidden;position:relative;left:-10000px;">&nbsp;</a></li>
                            </ul>

                            <div class="tableContent">
                                <a name="sell"></a>

                                <table class="data sort_table" id="orders">
                                    <thead>
                                        <tr>
                                            <th>Date</th>
                                            <th>Type</th>
                                            <th>Status</th>
                                            <th>Amount</th>
                                            <th>Price</th>
                                            <th>Total</th>
                                            <th>Currency</th>
                                            <th>Cancel</th>
                                        </tr>
                                    </thead>
                                </table>

                            </div>

                        </form>
                    
                </div>
                
            </div>
            
            <footer>
    <nav class="line">
        <ul class="unit size2of5 line"><h4>Quick Links</h4>
            <li class="size1of2 unit"><a href="/trade" title="Trade">Trade</a></li>
            <li class="size1of2 unit"><a href="/api" title="Trade API">Trade API</a></li>
            <!-- li class="size1of2 unit"><a href="/merchant" title="Merchant integration">Merchant integration</a></li -->
            <li class="size1of2 unit"><a href="https://support.mtgox.com/" title="Support">Support</a></li>
            <li class="size1of2 unit"><a href="/fee-schedule" title="Fee Schedule">Fee Schedule</a></li>
            <li class="size1of2 unit"><a href="/forms/verification" title="Get verified">Get verified</a></li>
            <li class="size1of2 unit"><a href="https://support.mtgox.com/forums/20105883-faq " title="FAQ">FAQ</a></li>
            <li class="size1of2 unit"><a href="/privacy_policy" title="Privacy Policy">Privacy Policy</a></li>
            <li class="size1of2 unit"><a href="/terms_of_service" title="Terms of Use">Terms of Use</a></li>
        </ul>

        <ul class="unit size1of5 line"><h4>Our Company</h4>
            <li class="size1of2 unit"><a href="/about-us" title="About Us">About Us</a></li>
            <li class="size1of2 unit"><a href="/contact-us" title="Contact Us">Contact Us</a></li>
        </ul>

        <div class="unit size1of5">
            <ul class="line"><h4>Apps And Social</h4>
                <li class="unit"><figure>&nbsp;<a href="/mobile" class="icons iconAndroid" title="Mt. Gox Android application">Mt. Gox Android application</a></figure></li>
                <li class="unit">&nbsp;<a href="http://www.facebook.com/MtGox" class="icons iconFb">Facebook</a></li>
                <li class="lastUnit"><a class="g-plusone" href="https://plus.google.com/100448119000434100275" target="_blank"></a></li>
            </ul>
        </div>



      <div class="size1of5 lastUnit">
        <div title="Click to Verify - This site chose VeriSign Trust Seal to promote trust online with consumers." style="background-image: url(/img/baby_harp_seal.gif);background-repeat:no-repeat;background-position:0 7px;"><script type="text/javascript" src="https://seal.verisign.com/getseal?host_name=mtgox.com&amp;size=L&amp;use_flash=NO&amp;use_transparent=YES&amp;lang=en"></script>
          <a href="http://www.verisign.com/verisign-trust-seal" target="_blank"  style="color:#000000; text-decoration:none; font:bold 7px verdana,sans-serif; letter-spacing:.5px; text-align:center; margin:0px; padding:0px;"></a>
        </div>
      </div>
    </nav>

    <span class="copyright">
        &nbsp;<span href="/" class="icons logoFooter">Mt. Gox</span> &copy; 2010 - 2012 Tibanne Co. Ltd. (Japan)
        |
        
      
      <a href="/trade?Locale=en_US" class="currency flags" style="background-image: url(https://mtgox.com/common/img/flags/us.png);">&nbsp;</a>&nbsp;
      
      <a href="/trade?Locale=pl_PL" class="currency flags" style="background-image: url(https://mtgox.com/common/img/flags/pl.png);">&nbsp;</a>&nbsp;
      
    
    </span>
</footer>

<!-- script type="text/javascript" src="https://socketio.mtgox.com/socket.io/socket.io.js"></script -->
            
        </div>
    </body>
    
</html>
