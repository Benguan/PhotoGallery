﻿<%@ Page Title="" Language="C#" MasterPageFile="~/Master/share.Master" AutoEventWireup="false" CodeBehind="Default.aspx.cs" Inherits="PhotoGallery.Website.Default" %>
<asp:Content ID="Content2" ContentPlaceHolderID="contentHeader" runat="server">
    <link href="/Resources/css/wall.css" rel="stylesheet" />

</asp:Content>
<asp:Content ID="Content1" ContentPlaceHolderID="ContentArticle" runat="server">
    <div class="container body-content">
    <div class="wall ">

        <div class="page view">

            <div class="origin view">
                <div id="camera" class="view">
                    <div id="dolly" class="view">
                        <div id="title" class="view">

                        </div>	
                        <div id="stack" class="view">
                        </div>
                        <div id="mirror" class="view">
                            <div id="rstack" class="view">
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </div>
    </div>

    <script type="text/javascript">

        var CWIDTH;
        var CHEIGHT;
        var CGAP = 10;
        var CXSPACING;
        var CYSPACING;

        function translate3d(x, y, z) {
            return "translate3d(" + x + "px, " + y + "px, " + z + "px)";
        }

        function cameraTransformForCell(n) {
            var x = Math.floor(n / 3);
            var y = n - x * 3;
            var cx = (x + 0.5) * CXSPACING;
            var cy = (y + 0.5) * CYSPACING;

            if (magnifyMode) {
                return translate3d(-cx, -cy, 180);
            }
            else {
                return translate3d(-cx, -cy, 0);
            }
        }

        var currentCell = -1;

        var cells = [];

        var currentTimer = null;

        var dolly = jQuery("#dolly")[0];
        var camera = jQuery("#camera")[0];

        var magnifyMode = false;

        var zoomTimer = null;

        function refreshImage(elem, cell) {
            if (cell.iszoomed) {
                return;
            }

            if (zoomTimer) {
                clearTimeout(zoomTimer);
            }

            var zoomImage = jQuery('<img class="zoom"></img>');

            zoomTimer = setTimeout(function () {
                zoomImage.load(function () {
                    layoutImageInCell(zoomImage[0], cell.div[0]);
                    jQuery(elem).replaceWith(zoomImage);
                    cell.iszoomed = true;
                });

                zoomImage.attr("src", cell.info.zoom);

                zoomTimer = null;
            }, 2000);
        }

        function layoutImageInCell(image, cell) {
            var iwidth = image.width;
            var iheight = image.height;
            var cwidth = jQuery(cell).width();
            var cheight = jQuery(cell).height();
            var ratio = Math.min(cheight / iheight, cwidth / iwidth);

            iwidth *= ratio;
            iheight *= ratio;

            image.style.width = Math.round(iwidth) + "px";
            image.style.height = Math.round(iheight) + "px";

            image.style.left = Math.round((cwidth - iwidth) / 2) + "px";
            image.style.top = Math.round((cheight - iheight) / 2) + "px";
        }

        function updateStack(newIndex, newmagnifymode) {
            if (currentCell == newIndex && magnifyMode == newmagnifymode) {
                return;
            }

            var oldIndex = currentCell;
            newIndex = Math.min(Math.max(newIndex, 0), cells.length - 1);
            currentCell = newIndex;

            if (oldIndex != -1) {
                var oldCell = cells[oldIndex];
                oldCell.div.attr("class", "cell fader view original");
                if (oldCell.reflection) {
                    oldCell.reflection.attr("class", "cell fader view reflection");
                }
            }

            var cell = cells[newIndex];
            cell.div.addClass("selected");

            if (cell.reflection) {
                cell.reflection.addClass("selected");
            }

            magnifyMode = newmagnifymode;

            if (magnifyMode) {
                cell.div.addClass("magnify");
                refreshImage(cell.div.find("img")[0], cell);
            }

            dolly.style.webkitTransform = cameraTransformForCell(newIndex);

            var currentMatrix = new WebKitCSSMatrix(document.defaultView.getComputedStyle(dolly, null).webkitTransform);
            var targetMatrix = new WebKitCSSMatrix(dolly.style.webkitTransform);

            var dx = currentMatrix.e - targetMatrix.e;
            //var angle = Math.min(Math.max(dx / (CXSPACING * 3.0), -1), 1) * 45;

            //var angle = dx>0?30:-30;
            var angle = newIndex == 1 ? 0 : 30;

            camera.style.webkitTransform = "rotateY(" + angle + "deg)";
            camera.style.webkitTransitionDuration = "0ms";

        }

        function snowstack_addimage(reln, info) {

            var cell = {};
            var realn = cells.length;
            cells.push(cell);

            var x = Math.floor(realn / 3);
            var y = realn - x * 3;

            cell.info = info;

            cell.div = jQuery('<div class="cell fader view original" style="opacity: 0"></div>').width(CWIDTH).height(CHEIGHT);
            cell.title = jQuery('<div class="cell fader view original" style="opacity: 1"></div>').width(CWIDTH * 3).height(50);

            cell.div[0].style.webkitTransform = translate3d(x * CXSPACING, y * CYSPACING, 0);
            cell.title[0].style.webkitTransform = translate3d(x * CXSPACING, y * CYSPACING, 0);

            var img = document.createElement("img");

            jQuery(img).load(function () {
                layoutImageInCell(img, cell.div[0]);
                cell.div.append(jQuery('<a class="mover viewflat" href="' + cell.info.link + '" target="_blank"></a>').append(img));

                cell.div.css("opacity", 1);
            });

            img.src = info.thumb;

            jQuery("#stack").append(cell.div);

            if (y === 0 && (x % 3 === 0)) {
                cell.title[0].innerHTML = info.year + " " + info.categoryName;
                jQuery("#title").append(cell.title);
            }

            if (y == 2) {
                cell.reflection = jQuery('<div class="cell fader view reflection" style="opacity: 0"></div>').width(CWIDTH).height(CHEIGHT);
                cell.reflection[0].style.webkitTransform = translate3d(x * CXSPACING, y * CYSPACING, 0);

                var rimg = document.createElement("img");

                jQuery(rimg).load(function () {
                    layoutImageInCell(rimg, cell.reflection[0]);
                    cell.reflection.append(jQuery('<div class="mover viewflat"></div>').append(rimg));
                    cell.reflection.css("opacity", 1);
                });

                rimg.src = info.thumb;

                jQuery("#rstack").append(cell.reflection);
            }
        }

        function snowstack_init() {
            CHEIGHT = Math.round(window.innerHeight / 5);
            CWIDTH = Math.round(CHEIGHT * 300 / 180);
            CXSPACING = CWIDTH + CGAP;
            CYSPACING = CHEIGHT + CGAP;

            jQuery("#mirror")[0].style.webkitTransform = "scaleY(-1.0) " + translate3d(0, -CYSPACING * 6 - 1, 0);
        }


        jQuery(window).load(function () {
            var page = 1;
            var loading = true;

            snowstack_init();

            flickr(function (images) {
                jQuery.each(images, snowstack_addimage);
                updateStack(1);
                loading = false;
            }, page);

            var keys = { left: false, right: false, up: false, down: false };

            var keymap = { 37: "left", 38: "up", 39: "right", 40: "down" };

            var keytimer = null;

            function updatekeys() {
                var newcell = currentCell;
                if (keys.left || keys.up) {
                    /* Left Arrow */
                    if (newcell >= 3) {
                        newcell -= 3;
                    }
                }
                if (keys.right || keys.down) {
                    /* Right Arrow */

                    if ((newcell + 3) < cells.length) {
                        newcell += 3;
                    }

                    if (!loading && (newcell + 15) > cells.length) {
                        /* We hit the right wall, add some more */
                        page = page + 2;
                        loading = true;
                        flickr(function (images) {
                            jQuery.each(images, snowstack_addimage);
                            loading = false;
                        }, page);
                    }
                }

                updateStack(newcell, magnifyMode);
            }

            function updateKeyByWheel(wheel) {
                var newcell = currentCell;

                if (wheel > 0) {
                    /* Left Arrow */
                    if (newcell >= 3) {
                        newcell -= 3;
                    }
                }

                if (wheel <= 0) {
                    /* Right Arrow */
                    if ((newcell + 3) < cells.length) {
                        newcell += 3;
                    }

                    if (!loading && (newcell + 15) > cells.length) {
                        /* We hit the right wall, add some more */
                        page = page + 2;
                        loading = true;
                        flickr(function (images) {
                            jQuery.each(images, snowstack_addimage);                            loading = false;
                        }, page);
                    }
                }

                updateStack(newcell, magnifyMode);
            }

            var scrollFunc = function (e) {
                var wheelDelta = 0;
                if (e.wheelDelta) { //IE/Opera/Chrome
                    wheelDelta = e.wheelDelta;
                } else if (e.detail) { //Firefox
                    wheelDelta = e.detail;
                }

                updateKeyByWheel(wheelDelta);
            };

            if (document.addEventListener) {
                document.addEventListener('DOMMouseScroll', scrollFunc, false);
            }//W3C
            window.onmousewheel = document.onmousewheel = scrollFunc;//IE/Opera/Chro


            var delay = 300;

            function keycheck() {

                if (keys.left || keys.right || keys.up || keys.down) {
                    if (keytimer === null) {
                        var doTimer = function () {
                            updatekeys();
                            keytimer = setTimeout(doTimer, delay);
                            delay = 60;

                        };
                        doTimer();
                    }
                }
                else {
                    clearTimeout(keytimer);
                    keytimer = null;
                }
            }

            /* Limited keyboard support for now */
            window.addEventListener('keydown', function (e) {
                if (e.keyCode == 32) {
                    /* Magnify toggle with spacebar */
                    updateStack(currentCell, !magnifyMode);
                }
                else {
                    keys[keymap[e.keyCode]] = true;
                }

                keycheck();
            });

            window.addEventListener('keyup', function (e) {
                keys[keymap[e.keyCode]] = false;
                keycheck();
            });
        });

        function flickr(callback, page) {
            var apiHost = "";
            var api = "API/GetDetails.aspx?ids=" + page + "," + ++page + "&page=1";
            var album = "/Home/Album";
            var url = apiHost + api;

            jQuery.ajax({
                url: url,
                processData: false,
                cache: true,
                dataType: "jsonp",
                jsonpCallback: "receive",
                success: function (data) {
                    var images = [];
                    for (var i = 0; i < data.length; i++) {
                        for (var j = 0; j < data[i].photos.length; j++) {

                            var item = data[i].photos[j];
                            images.push({
                                thumb: item ? apiHost + item.thumbnailUrl : "",
                                zoom: item ? apiHost + item.thumbnailUrl : "",
                                link: item ? apiHost + album + "?categoryId=" + data[i].id + "&photoId=" + item.id : "",
                                categoryName: data[i] ? data[i].name : "",
                                year: data[i] ? data[i].year : "",
                            });
                        }
                    }
                    //return {
                    //    thumb: item ? apiHost + item.thumbnailUrl : "",
                    //    zoom: item ? apiHost + item.thumbnailUrl : "",
                    //    link: item ? apiHost + album + "?categoryId=" + data.id + "&photoId=" + item.id : "",
                    //    categoryName: data ? data.name : "",
                    //    year: data ? data.year : "",
                    //};
                    callback(images);
                }
            })
        }

    </script>

</div>
</asp:Content>

<asp:Content ID="Content3" ContentPlaceHolderID="contentFooter" runat="server"></asp:Content>