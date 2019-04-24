<?php
require_once('qa-include/vendor/PHPMailer/PHPMailerAutoload.php');
//C:\wamp64\www\qa-include\vendor\PHPMailer
//include("class.smtp.php"); // optional, gets called from within class.phpmailer.php if not already loaded
include('password.php');

$mail             = new PHPMailer();

$body             = 'Test mail';

$mail->IsSMTP(); // telling the class to use SMTP
$mail->SMTPDebug  = 2;                     // enables SMTP debug information (for testing)
                                           // 1 = errors and messages
                                           // 2 = messages only
$mail->SMTPAuth   = true;                  // enable SMTP authentication
$mail->SMTPSecure = "ssl";                 // sets the prefix to the servier
$mail->Host       = "smtp.gmail.com";      // sets GMAIL as the SMTP server
$mail->Port       = 465;                   // set the SMTP port for the GMAIL server
$mail->Username   = "jonathanslester@gmail.com";  // GMAIL username
$mail->Password   = $password;            // GMAIL password

$mail->SetFrom('no-reply@lester.com', 'Jonathan Lester');


$mail->Subject    = "PHPMailer Test Subject via smtp (Gmail), basic";

$mail->AltBody    = "To view the message, please use an HTML compatible email viewer!"; // optional, comment out and test

$mail->MsgHTML($body);

$address = "jonathanslester@gmail.com";
$mail->AddAddress($address, "Jonathan Lester");


if(!$mail->Send()) {
  echo "Mailer Error: " . $mail->ErrorInfo;
} else {
  echo "Message sent!";
}
?>   
