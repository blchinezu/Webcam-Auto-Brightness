<?php

$img=imagecreatefromjpeg('wc.jpeg');

imagefilter($img, IMG_FILTER_CONTRAST, -17);
#imagejpeg($img, 'wc2.jpeg', 75);

$w = imagesx($img);
$h = imagesy($img);

$pixels_brightness=0;
$steps=0;
for($y=0;$y<$h;$y++)
{
	for($x=0;$x<$w;$x++)
	{
		$rgb = imagecolorat($img, $x, $y);
		$r = ($rgb >> 16) & 0xFF;
		$g = ($rgb >> 8) & 0xFF;
		$b = $rgb & 0xFF;
		$pixels_brightness+=0.299 * $r + 0.587 * $g + 0.114 * $b;
		$steps+=1;
	}
}
imagedestroy($img);

$img_brightness=$pixels_brightness / $steps;
echo "$img_brightness";
?>
