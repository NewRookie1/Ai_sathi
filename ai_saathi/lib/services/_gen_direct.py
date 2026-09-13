#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Generate localization_service.dart directly with all translations inline.
"""
import os

OUT = r'C:\Users\calvi\Downloads\SIH_Project_2\ai_saathi\lib\services\localization_service.dart'

# All translations organized by language
# en keys are used as the reference; other languages provide native translations

KEYS = [
    "app_name","app_tagline",
    "onboarding_speak_title","onboarding_speak_desc",
    "onboarding_scan_title","onboarding_scan_desc",
    "onboarding_pricing_title","onboarding_pricing_desc",
    "onboarding_grow_title","onboarding_grow_desc",
    "next","get_started","skip","welcome_back","create_account",
    "sign_in_continue","join_artisan","full_name","enter_name",
    "email","enter_email","valid_email","password","enter_password",
    "password_length","sign_in","no_account","have_account","demo_mode",
    "hello_artisan","what_today","quick_actions","scan_product","my_products",
    "orders","market","recent_products","view_all","recent_orders","pending",
    "search_products","no_products","add_first","add_product","new_orders",
    "pending_orders","all_orders","no_new_orders","no_pending_orders",
    "no_orders","total","items","more_items","market_analysis","trending_now",
    "no_trending","listings","market_insights","avg_price","total_listings",
    "demand_score","demand","demand_high","demand_medium","demand_low",
    "profile","language","notifications","shop_settings","payment_settings",
    "help_support","about","version","rate_app","logout","logout_confirm",
    "cancel","voice_assistant","switch_to_voice","switch_to_text",
    "speak_or_type","speak_example","processing","type_command_lang",
    "tap_speak","mic_unavailable","type_command","mic_permission_denied",
    "use_text","recording_failed","no_audio_captured","recording_failed_text",
    "stt_failed","connection_error","opening_home","opening_products",
    "opening_orders","opening_market","opening_profile","opening_scanner",
    "opening_pricing","opening_add_product","checking_orders","help_text",
    "going_back","unknown_command","product_name","product_name_hint",
    "enter_product_name","description","describe_product","enter_description",
    "category","material","material_hint","craft_type","craft_hint",
    "price_rs","enter_price","valid_price","quantity","tags","add_tag",
    "save_product","product_created","product_create_failed","take_photo",
    "product_analysis","add_to_catalog","camera_init_failed","analyze_failed",
    "capture_failed","analyzing","point_camera","price_assistant","pricing_info",
    "product_details","product_category","category_hint","enter_category",
    "material_cost","labor_cost","get_price","suggested_price","estimate",
    "confidence","price_failed","product_not_found","pricing","current_price",
    "suggested_range","performance","views","sold","revenue","price_suggestion",
    "close","delete_product","delete_confirm","delete","order_details",
    "order_not_found","buyer_info","order_items","order_summary","total_amount",
    "shipping_address","reject","accept","cancel_order","no","yes_cancel",
    "order_accepted","order_rejected","order_cancelled","cancel_confirm",
    "image_studio","save","processing_image","select_image","tools","enhance",
    "remove_bg","crop","ecommerce","process_failed","image_saved",
    "nav_home","nav_products","nav_orders","nav_market","nav_profile",
]

# English values
EN = {
    "app_name":"AI Saathi","app_tagline":"Your Smart Artisan Companion",
    "onboarding_speak_title":"Speak Your Product","onboarding_speak_desc":"Simply describe your product in your own language and let AI create a professional listing.",
    "onboarding_scan_title":"Scan and Identify","onboarding_scan_desc":"Point your camera at any product to get instant details and pricing suggestions.",
    "onboarding_pricing_title":"Smart Pricing","onboarding_pricing_desc":"Get AI-powered pricing recommendations based on market trends and your costs.",
    "onboarding_grow_title":"Grow Your Business","onboarding_grow_desc":"Track orders, analyze markets, and scale your artisan business with smart insights.",
    "next":"Next","get_started":"Get Started","skip":"Skip","welcome_back":"Welcome Back","create_account":"Create Account",
    "sign_in_continue":"Sign in to continue","join_artisan":"Join thousands of artisans","full_name":"Full Name","enter_name":"Enter your name",
    "email":"Email","enter_email":"Enter your email","valid_email":"Please enter a valid email","password":"Password","enter_password":"Enter your password",
    "password_length":"Password must be at least 6 characters","sign_in":"Sign In","no_account":"Don't have an account?","have_account":"Already have an account?","demo_mode":"Try Demo Mode",
    "hello_artisan":"Hello, Artisan!","what_today":"What would you like to do today?","quick_actions":"Quick Actions","scan_product":"Scan Product","my_products":"My Products",
    "orders":"Orders","market":"Market","recent_products":"Recent Products","view_all":"View All","recent_orders":"Recent Orders","pending":"Pending",
    "search_products":"Search products...","no_products":"No Products Yet","add_first":"Add your first product to get started","add_product":"Add Product","new_orders":"New Orders",
    "pending_orders":"Pending Orders","all_orders":"All Orders","no_new_orders":"No new orders","no_pending_orders":"No pending orders","no_orders":"No orders yet",
    "total":"Total","items":"items","more_items":"more","market_analysis":"Market Analysis","trending_now":"Trending Now","no_trending":"No trending products yet",
    "listings":"Listings","market_insights":"Market Insights","avg_price":"Avg Price","total_listings":"Total Listings","demand_score":"Demand Score","demand":"Demand",
    "demand_high":"High","demand_medium":"Medium","demand_low":"Low","profile":"Profile","language":"Language","notifications":"Notifications",
    "shop_settings":"Shop Settings","payment_settings":"Payment Settings","help_support":"Help & Support","about":"About","version":"Version","rate_app":"Rate App",
    "logout":"Logout","logout_confirm":"Are you sure you want to logout?","cancel":"Cancel","voice_assistant":"Voice Assistant","switch_to_voice":"Switch to Voice",
    "switch_to_text":"Switch to Text","speak_or_type":"Speak or type your command","speak_example":"Try saying: create new product listing","processing":"Processing...",
    "type_command_lang":"Type your command in your language...","tap_speak":"Tap to speak","mic_unavailable":"Microphone unavailable","type_command":"Type command",
    "mic_permission_denied":"Microphone permission denied","use_text":"Use text input instead","recording_failed":"Recording failed","no_audio_captured":"No audio captured",
    "recording_failed_text":"Recording failed","stt_failed":"Speech recognition failed","connection_error":"Connection error",
    "opening_home":"Opening home...","opening_products":"Opening products...","opening_orders":"Opening orders...","opening_market":"Opening market...",
    "opening_profile":"Opening profile...","opening_scanner":"Opening scanner...","opening_pricing":"Opening pricing...","opening_add_product":"Opening add product...",
    "checking_orders":"Checking orders...","help_text":"I am your AI assistant. How can I help you today?","going_back":"Going back...","unknown_command":"Sorry, I did not understand that",
    "product_name":"Product Name","product_name_hint":"e.g. Handwoven Pottery Vase","enter_product_name":"Enter product name","description":"Description",
    "describe_product":"Describe your product","enter_description":"Enter product description","category":"Category","material":"Material","material_hint":"e.g. Cotton, Silk, Wood",
    "craft_type":"Craft Type","craft_hint":"e.g. Pottery, Weaving, Carving","price_rs":"Price (Rs)","enter_price":"Enter price","valid_price":"Please enter a valid price",
    "quantity":"Quantity","tags":"Tags","add_tag":"Add Tag","save_product":"Save Product","product_created":"Product created successfully!",
    "product_create_failed":"Failed to create product","take_photo":"Take Photo","product_analysis":"Product Analysis","add_to_catalog":"Add to Catalog",
    "camera_init_failed":"Failed to initialize camera","analyze_failed":"Failed to analyze product","capture_failed":"Failed to capture image","analyzing":"Analyzing...",
    "point_camera":"Point camera at product","price_assistant":"Price Assistant","pricing_info":"AI Pricing Suggestion","product_details":"Product Details",
    "product_category":"Product Category","category_hint":"e.g. Pottery, Jewelry, Textiles","enter_category":"Enter category","material_cost":"Material Cost (Rs)",
    "labor_cost":"Labor Cost (Rs)","get_price":"Get Price Suggestion","suggested_price":"Suggested Price","estimate":"Estimate","confidence":"Confidence",
    "price_failed":"Failed to get price suggestion","product_not_found":"Product not found","pricing":"Pricing","current_price":"Current Price",
    "suggested_range":"Suggested Range","performance":"Performance","views":"Views","sold":"Sold","revenue":"Revenue","price_suggestion":"Price Suggestion",
    "close":"Close","delete_product":"Delete Product","delete_confirm":"Are you sure you want to delete this product?","delete":"Delete",
    "order_details":"Order Details","order_not_found":"Order not found","buyer_info":"Buyer Information","order_items":"Order Items","order_summary":"Order Summary",
    "total_amount":"Total Amount","shipping_address":"Shipping Address","reject":"Reject","accept":"Accept","cancel_order":"Cancel Order","no":"No",
    "yes_cancel":"Yes, Cancel","order_accepted":"Order accepted!","order_rejected":"Order rejected","order_cancelled":"Order cancelled",
    "cancel_confirm":"Are you sure you want to cancel this order?","image_studio":"Image Studio","save":"Save","processing_image":"Processing image...",
    "select_image":"Select an image to edit","tools":"Tools","enhance":"Enhance","remove_bg":"Remove Background","crop":"Crop","ecommerce":"E-commerce Ready",
    "process_failed":"Failed to process image","image_saved":"Image saved!",
    "nav_home":"Home","nav_products":"Products","nav_orders":"Orders","nav_market":"Market","nav_profile":"Profile",
}

# Hindi translations
HI = {
    "app_name":"\u0906\u0908 \u0938\u093e\u0925\u0940","app_tagline":"\u0906\u092a\u0915\u093e \u0938\u094d\u092e\u093e\u0930\u094d\u091f \u0915\u093e\u0930\u0940\u0917\u0930 \u0938\u093e\u0925\u0940",
    "onboarding_speak_title":"\u0905\u092a\u0928\u093e \u0909\u0924\u094d\u092a\u093e\u0926 \u092c\u094b\u0932\u0947\u0902","onboarding_speak_desc":"\u092c\u0938 \u0905\u092a\u0928\u0940 \u092d\u093e\u0937\u093e \u092e\u0947\u0902 \u0905\u092a\u0928\u0947 \u0909\u0924\u094d\u092a\u093e\u0926 \u0915\u093e \u0935\u0930\u094d\u0923\u0928 \u0915\u0930\u0947\u0902 \u0914\u0930 AI \u0915\u094b \u092a\u0947\u0936\u0947\u0935\u0930 \u0932\u093f\u0938\u094d\u091f\u093f\u0902\u0917 \u092c\u0928\u093e\u0928\u0947 \u0926\u0947\u0902\u0964",
    "onboarding_scan_title":"\u0938\u094d\u0915\u0948\u0928 \u0914\u0930 \u092a\u0939\u091a\u093e\u0928\u0947\u0902","onboarding_scan_desc":"\u0924\u0941\u0930\u0902\u0924 \u0935\u093f\u0935\u0930\u0923 \u0914\u0930 \u092e\u0942\u0932\u094d\u092f \u0938\u0941\u091d\u093e\u0935 \u092a\u093e\u0928\u0947 \u0915\u0947 \u0932\u093f\u090f \u0905\u092a\u0928\u093e \u0915\u0948\u092e\u0930\u093e \u0915\u093f\u0938\u0940 \u092d\u0940 \u0909\u0924\u094d\u092a\u093e\u0926 \u092a\u0930 \u0928\u093f\u0930\u094d\u0926\u0947\u0936\u093f\u0924 \u0915\u0930\u0947\u0902\u0964",
    "onboarding_pricing_title":"\u0938\u094d\u092e\u093e\u0930\u094d\u091f \u092e\u0942\u0932\u094d\u092f \u0928\u093f\u0930\u094d\u0927\u093e\u0930\u0923","onboarding_pricing_desc":"\u092c\u093e\u091c\u093e\u0930 \u0915\u0947 \u0930\u0941\u091d\u093e\u0928 \u0914\u0930 \u0906\u092a\u0915\u0940 \u0932\u093e\u0917\u0924 \u0915\u0947 \u0906\u0927\u093e\u0930 \u092a\u0930 AI-\u0938\u0902\u091a\u093e\u0932\u093f\u0924 \u092e\u0942\u0932\u094d\u092f \u0938\u093f\u092b\u093e\u0930\u093f\u0936\u0947\u0902 \u092a\u094d\u0930\u093e\u092a\u094d\u0924 \u0915\u0930\u0947\u0902\u0964",
    "onboarding_grow_title":"\u0905\u092a\u0928\u093e \u0935\u094d\u092f\u0935\u0938\u093e\u092f \u092c\u0922\u093c\u093e\u090f\u0902","onboarding_grow_desc":"\u0911\u0930\u094d\u0921\u0930 \u091f\u094d\u0930\u0948\u0915 \u0915\u0930\u0947\u0902, \u092c\u093e\u091c\u093e\u0930\u094b\u0902 \u0915\u093e \u0935\u093f\u0936\u094d\u0932\u0947\u0937\u0923 \u0915\u0930\u0947\u0902 \u0914\u0930 \u0938\u094d\u092e\u093e\u0930\u094d\u091f \u0907\u0902\u0938\u093e\u0907\u091f\u094d\u091f \u0938\u0947 \u0905\u092a\u0928\u0947 \u0935\u094d\u092f\u0935\u0938\u093e\u092f \u0915\u094b \u092c\u0922\u093c\u093e\u090f\u0902\u0964",
    "next":"\u0905\u0917\u0932\u093e","get_started":"\u0936\u0941\u0930\u0942 \u0915\u0930\u0947\u0902","skip":"\u091b\u094b\u0921\u093c\u0947\u0902","welcome_back":"\u0935\u093e\u092a\u0938 \u0938\u094d\u0935\u093e\u0917\u0924 \u0939\u0948\u0902","create_account":"\u0916\u093e\u0924\u093e \u092c\u0928\u093e\u090f\u0902",
    "sign_in_continue":"\u091c\u093e\u0930\u0940 \u0930\u0916\u0928\u0947 \u0915\u0947 \u0932\u093f\u090f \u0938\u093e\u0907\u0928 \u0907\u0928 \u0915\u0930\u0947\u0902","join_artisan":"\u0939\u091c\u093e\u0930\u094b\u0902 \u0915\u0940 \u0938\u0902\u0916\u094d\u092f\u093e \u092e\u0947\u0902 \u0936\u093e\u092e\u093f\u0932 \u0939\u094b\u0902","full_name":"\u092a\u0942\u0930\u093e \u0928\u093e\u092e","enter_name":"\u0905\u092a\u0928\u093e \u0928\u093e\u092e \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902",
    "email":"\u0908\u092e\u0947\u0932","enter_email":"\u0905\u092a\u0928\u093e \u0908\u092e\u0947\u0932 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","valid_email":"\u0915\u0943\u092a\u092f\u093e \u0935\u0948\u0927 \u0908\u092e\u0947\u0932 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","password":"\u092a\u093e\u0938\u0935\u0930\u094d\u0921","enter_password":"\u0905\u092a\u0928\u093e \u092a\u093e\u0938\u0935\u0930\u094d\u0921 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902",
    "password_length":"\u092a\u093e\u0938\u0935\u0930\u094d\u0921 \u0915\u092e \u0938\u0947 \u0915\u092e \u0905\u0915\u094d\u0937\u0930 \u0915\u093e \u0939\u094b\u0928\u093e \u091a\u093e\u0939\u093f\u090f","sign_in":"\u0938\u093e\u0907\u0928 \u0907\u0928","no_account":"\u0916\u093e\u0924\u093e \u0928\u0939\u0940\u0902 \u0939\u0948?","have_account":"\u092a\u0939\u0932\u0947 \u0938\u0947 \u0939\u0940 \u0916\u093e\u0924\u093e \u0939\u0948?","demo_mode":"\u0921\u0947\u092e\u094b \u092e\u094b\u0921 \u0906\u091c\u092e\u093e\u090f\u0902",
    "hello_artisan":"\u0928\u092e\u0938\u094d\u0915\u093e\u0930, \u0915\u093e\u0930\u093f\u0917\u0930!","what_today":"\u0906\u091c \u0906\u092a\u0915\u094b \u0915\u094d\u092f\u093e \u0915\u0930\u0928\u093e \u0939\u0948?","quick_actions":"\u091c\u0932\u0926 \u0915\u093e\u0930\u094d\u092f\u0935\u093e\u0939\u0940","scan_product":"\u0909\u0924\u094d\u092a\u093e\u0926\u0939\u093e\u0930 \u0938\u094d\u0915\u0948\u0928 \u0915\u0930\u0947\u0902","my_products":"\u092e\u0947\u0930\u0947 \u0909\u0924\u094d\u092a\u093e\u0926",
    "orders":"\u0911\u0930\u094d\u0921\u0930","market":"\u092c\u093e\u091c\u093e\u0930","recent_products":"\u0939\u093e\u0932 \u0915\u0947 \u0909\u0924\u094d\u092a\u093e\u0926","view_all":"\u0938\u092c \u0926\u0947\u0916\u0947\u0902","recent_orders":"\u0939\u093e\u0932 \u0915\u0947 \u0911\u0930\u094d\u0921\u0930","pending":"\u0932\u0902\u092c\u093f\u0924",
    "search_products":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0916\u094b\u091c\u0947\u0902...","no_products":"\u0905\u092d\u0940 \u0924\u0915 \u0915\u094b\u0908 \u0909\u0924\u094d\u092a\u093e\u0926 \u0928\u0939\u0940\u0902","add_first":"\u0936\u0941\u0930\u0942 \u0915\u0930\u0928\u0947 \u0915\u0947 \u0932\u093f\u090f \u092a\u0939\u0932\u093e \u0909\u0924\u094d\u092a\u093e\u0926 \u091c\u094b\u0921\u093c\u0947\u0902","add_product":"\u0909\u0924\u094d\u092a\u093e\u0926 \u091c\u094b\u0921\u093c\u0947\u0902","new_orders":"\u0928\u090f \u0911\u0930\u094d\u0921\u0930",
    "pending_orders":"\u0932\u0902\u092c\u093f\u0924 \u0911\u0930\u094d\u0921\u0930","all_orders":"\u0938\u092d\u0940 \u0911\u0930\u094d\u0921\u0930","no_new_orders":"\u0915\u094b\u0908 \u0928\u090f \u0911\u0930\u094d\u0921\u0930 \u0928\u0939\u0940\u0902","no_pending_orders":"\u0915\u094b\u0908 \u0932\u0902\u092c\u093f\u0924 \u0911\u0930\u094d\u0921\u0930 \u0928\u0939\u0940\u0902","no_orders":"\u0905\u092d\u0940 \u0924\u0915 \u0911\u0930\u094d\u0921\u0930 \u0928\u0939\u0940\u0902",
    "total":"\u0915\u0941\u0932","items":"\u0935\u0938\u094d\u0924\u0941\u090f\u0902","more_items":"\u0905\u0927\u093f\u0915","market_analysis":"\u092c\u093e\u091c\u093e\u0930 \u0935\u093f\u0936\u094d\u0932\u0947\u0937\u0923","trending_now":"\u0905\u092d\u0940 \u091f\u094d\u0930\u0947\u0902\u0921\u093f\u0902\u0917","no_trending":"\u0905\u092d\u0940 \u091f\u094d\u0930\u0947\u0902\u0921\u093f\u0902\u0917 \u0909\u0924\u094d\u092a\u093e\u0926 \u0928\u0939\u0940\u0902",
    "listings":"\u0938\u0942\u091a\u0928\u093e","market_insights":"\u092c\u093e\u091c\u093e\u0930 \u0905\u0902\u0924\u0930\u094d\u0926\u0943\u0937\u094d\u091f\u093f\u092f\u093e\u0902","avg_price":"\u0906\u0924 \u092e\u0942\u0932\u094d\u092f\u093e","total_listings":"\u0915\u0941\u0932 \u0938\u0942\u091a\u0928\u093e","demand_score":"\u092e\u093e\u0902\u0917 \u0938\u094d\u0915\u094b\u0930","demand":"\u092e\u093e\u0902\u0917",
    "demand_high":"\u0909\u091a\u094d\u091a","demand_medium":"\u092e\u0927\u094d\u092f\u092e","demand_low":"\u0915\u092e","profile":"\u092a\u094d\u0930\u094b\u092b\u093e\u0907\u0932","language":"\u092d\u093e\u0937\u093e","notifications":"\u0938\u0942\u091a\u0928\u093e\u090f\u0902",
    "shop_settings":"\u0926\u0941\u0915\u093e\u0928 \u0938\u0947\u091f\u093f\u0902\u0917","payment_settings":"\u092d\u0941\u0917\u0924\u093e\u0928 \u0938\u0947\u091f\u093f\u0902\u0917","help_support":"\u0938\u0939\u093e\u092f\u0924\u093e \u0938\u092e\u0930\u094d\u0925\u0928","about":"\u0939\u092e\u093e\u0930\u0947 \u092c\u093e\u0930\u0947 \u092e\u0947\u0902","version":"\u0938\u0902\u0938\u094d\u0915\u0930\u0923","rate_app":"\u0906\u092a\u094d\u0921 \u0930\u0947\u091f \u0915\u0930\u0947\u0902",
    "logout":"\u0932\u0949\u0917 \u0910\u0902\u091f","logout_confirm":"\u0915\u094d\u092f\u093e \u0906\u092a\u0915\u094b \u0935\u093e\u0915\u093e\u0908 \u0932\u0949\u0917 \u0910\u0902\u091f \u0915\u0930\u0928\u093e \u0939\u0948?","cancel":"\u0930\u0926\u094d\u0926","voice_assistant":"\u0935\u0949\u0907\u0938 \u0938\u0939\u093e\u092f\u0915","switch_to_voice":"\u0935\u0949\u0907\u0938 \u092a\u0930 \u0938\u094d\u0935\u093f\u091a\u093e\u0930","switch_to_text":"\u091f\u0947\u0915\u094d\u0938\u094d\u091f \u092a\u0930 \u0938\u094d\u0935\u093f\u091a\u093e\u0930",
    "speak_or_type":"\u0905\u092a\u0928\u093e \u0924\u0938\u094d\u0935\u0930 \u092c\u094b\u0932\u0947\u0902 \u092f\u093e \u091f\u093e\u0907\u092a \u0915\u0930\u0947\u0902","speak_example":"\u092a\u094d\u0930\u092f\u093e\u0938 \u0915\u0930\u0947\u0902: \u0928\u092f\u093e \u0909\u0924\u094d\u092a\u093e\u0926 \u0935\u093f\u0935\u0930\u0923 \u092c\u0928\u093e\u090f\u0902","processing":"\u092a\u094d\u0930\u0915\u094d\u0930\u093f\u092f\u093e \u0939\u094b \u0930\u0939\u0940 \u0939\u0948...",
    "type_command_lang":"\u0905\u092a\u0928\u093e \u092d\u093e\u0937\u093e \u092e\u0947\u0902 \u0906\u0926\u0947\u0936 \u091f\u093e\u0907\u092a \u0915\u0930\u0947\u0902...","tap_speak":"\u092c\u094b\u0932\u0923\u0947 \u0915\u0947 \u0932\u093f\u090f \u091f\u0948\u092a \u0915\u0930\u0947\u0902","mic_unavailable":"\u092e\u093e\u0907\u0915\u094d\u0930\u094b\u092b\u094b\u0928 \u0909\u092a\u0932\u092c\u094d\u0927","type_command":"\u0906\u0926\u0947\u0936 \u091f\u093e\u0907\u092a \u0915\u0930\u0947\u0902","mic_permission_denied":"\u092e\u093e\u0907\u0915\u094d\u0930\u094b\u092b\u094b\u0928 \u0905\u0928\u0941\u092e\u0924\u093f \u092e\u093f\u0932\u0940 \u0928\u0939\u0940\u0902","use_text":"\u092b\u093c\u0939\u0930 \u0924\u0935\u094b\u0902 \u0926\u094d\u0935\u093e\u0930\u093e \u0915\u093e \u0909\u092a\u092f\u094b\u0917 \u0915\u0930\u0947\u0902","recording_failed":"\u0930\u093f\u0915\u0949\u0930\u094d\u0921\u093f\u0902\u0917 \u0905\u092b\u0938\u0932","no_audio_captured":"\u0915\u094b\u0908 \u0906\u0935\u093e\u091c\u093c \u0930\u0947\u0915\u0949\u0930\u094d\u0921 \u0928\u0939\u0940\u0902","recording_failed_text":"\u0930\u093f\u0915\u0949\u0930\u094d\u0921\u093f\u0902\u0917 \u0905\u092b\u0938\u0932","stt_failed":"\u092d\u093e\u0937\u093e \u092a\u091b\u093e\u0939\u093e\u0928 \u0905\u092b\u0938\u0932","connection_error":"\u0915\u0928\u0947\u0915\u094d\u0936\u0928 \u0924\u094d\u0930\u0941\u091f\u0940",
    "opening_home":"\u0939\u094b\u092e \u0916\u0941\u0932 \u0930\u0939\u0940 \u0939\u0948...","opening_products":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","opening_orders":"\u0911\u0930\u094d\u0921\u0930 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","opening_market":"\u092c\u093e\u091c\u093e\u0930 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","opening_profile":"\u092a\u094d\u0930\u094b\u092b\u093e\u0907\u0932 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","opening_scanner":"\u0938\u094d\u0915\u0948\u0928\u0930 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","opening_pricing":"\u0915\u093f\u0902\u092e\u0924 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","opening_add_product":"\u0909\u0924\u094d\u092a\u093e\u0926 \u091c\u094b\u0921\u093c\u0928\u0947 \u0916\u0941\u0932 \u0930\u0939\u0947 \u0939\u0947\u0902...","checking_orders":"\u0911\u0930\u094d\u0921\u0930 \u091a\u0947\u0915 \u0930\u0939\u0947 \u0939\u0947\u0902...","help_text":"\u092e\u0948\u0902 \u0906\u092a\u0915\u093e AI \u0938\u0939\u093e\u092f\u0915 \u0939\u0942\u0902","going_back":"\u0935\u093e\u092a\u0938 \u091c\u093e \u0930\u0939\u0947 \u0939\u0948\u0902...","unknown_command":"\u092e\u093e\u092b\u093c \u0938\u092e\u091c\u093c\u093e \u0928\u0939\u0940\u0902",
    "product_name":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0915\u093e \u0928\u093e\u092e","product_name_hint":"\u091c\u0948\u0938\u0947: \u0939\u093e\u0925 \u092c\u0941\u0923\u0947 \u0935\u093e\u0932\u093e \u092e\u0942\u0930\u094d\u091f\u0940","enter_product_name":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0915\u093e \u0928\u093e\u092e \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","description":"\u0935\u093f\u0935\u0930\u0923","describe_product":"\u0905\u092a\u0928\u0947 \u0909\u0924\u094d\u092a\u093e\u0926 \u0915\u093e \u0935\u093f\u0935\u0930\u0923 \u0915\u0930\u0947\u0902","enter_description":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0915\u093e \u0935\u093f\u0935\u0930\u0923 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","category":"\u0936\u094d\u0930\u0947\u0923\u0940","material":"\u0938\u093e\u092e\u0917\u094d\u0930\u0940","material_hint":"\u091c\u0948\u0938\u0947: \u0938\u0942\u0924, \u0930\u0947\u0936\u092e, \u0932\u0915\u0921","craft_type":"\u0936\u093f\u0932\u094d\u092a \u0915\u093f\u0938\u092e","craft_hint":"\u091c\u0948\u0938\u0947: \u092e\u093f\u091f\u094d\u091f\u0940, \u092c\u0941\u0923\u093e\u0908, \u0928\u0915\u094d\u0936\u093e\u0915\u093e\u0930\u0940","price_rs":"\u0915\u093f\u0902\u092e\u0924 (\u20b9)","enter_price":"\u0915\u093f\u0902\u092e\u0924 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","valid_price":"\u0915\u0943\u092a\u092f\u093e \u0935\u0948\u0927 \u0915\u093f\u0902\u092e\u0924 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","quantity":"\u092e\u093e\u0924\u094d\u0930\u093e","tags":"\u091f\u0948\u0917","add_tag":"\u091f\u0948\u0917 \u091c\u094b\u0921\u093c\u0947\u0902","save_product":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0938\u093e\u091a\u0947\u0902","product_created":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0938\u092b\u093c\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u092c\u0928\u093e\u092f\u093e!","product_create_failed":"\u0909\u0924\u094d\u092a\u093e\u0926 \u092c\u0928\u093e\u0928\u0947 \u092e\u0947\u0902 \u0935\u093f\u092b\u093c\u0932","take_photo":"\u092b\u093c\u094b\u091f\u094b \u0916\u093f\u0902\u091a\u0947\u0902","product_analysis":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0935\u093f\u0936\u094d\u0932\u0947\u0937\u0923","add_to_catalog":"\u0915\u0948\u091f\u0932\u093e\u0917 \u092e\u0947\u0902 \u091c\u094b\u0921\u093c\u0947\u0902","camera_init_failed":"\u0915\u0948\u092e\u0930\u093e \u0936\u0941\u0930\u0942 \u0915\u0930\u0928\u0947 \u092e\u0947\u0902 \u0935\u093f\u092b\u093c\u0932","analyze_failed":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0935\u093f\u0936\u094d\u0932\u0947\u0937\u0923 \u092e\u0947\u0902 \u0935\u093f\u092b\u093c\u0932","capture_failed":"\u092b\u093c\u094b\u091f\u094b \u0915\u0948\u092a\u094d\u091a\u0930 \u0915\u0930\u0928\u0947 \u092e\u0947\u0902 \u0935\u093f\u092b\u093c\u0932","analyzing":"\u0935\u093f\u0936\u094d\u0932\u0947\u0937\u0923 \u0939\u094b \u0930\u0939\u0940 \u0939\u0948...","point_camera":"\u0915\u0948\u092e\u0930\u093e \u0909\u0924\u094d\u092a\u093e\u0926 \u092a\u0930 \u0930\u0939\u093e\u090f\u0902","price_assistant":"\u0915\u093f\u0902\u092e\u0924 \u0938\u0939\u093e\u092f\u0915","pricing_info":"AI \u0915\u093f\u0902\u092e\u0924 \u0938\u0941\u091c\u093e\u0935","product_details":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0935\u093f\u0935\u0930\u0923","product_category":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0936\u094d\u0930\u0947\u0923\u0940","category_hint":"\u091c\u0948\u0938\u0947: \u092e\u093f\u091f\u094d\u091f\u0940, \u0917\u0939\u0928\u093e, \u0935\u0938\u094d\u0924\u094d\u0930\u093e","enter_category":"\u0936\u094d\u0930\u0947\u0923\u0940 \u0926\u0930\u094d\u091c \u0915\u0930\u0947\u0902","material_cost":"\u0938\u093e\u092e\u0917\u094d\u0930\u0940 \u0932\u093e\u0917\u0924 (\u20b9)","labor_cost":"\u092e\u091c\u0926\u0942\u0930\u0940 \u0932\u093e\u0917\u0924 (\u20b9)","get_price":"\u0915\u093f\u0902\u092e\u0924 \u0938\u0941\u091c\u093e\u0935 \u0932\u0947\u0902","suggested_price":"\u0938\u0941\u091c\u093e\u0935\u093f\u0924 \u0915\u093f\u0902\u092e\u0924","estimate":"\u0905\u0902\u0926\u093e\u091c","confidence":"\u0935\u093f\u0936\u094d\u0935\u093e\u0938","price_failed":"\u0915\u093f\u0902\u092e\u0924 \u0938\u0941\u091c\u093e\u0935 \u092e\u0947\u0902 \u0935\u093f\u092b\u093c\u0932","product_not_found":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0928\u0939\u0940\u0902 \u092e\u093f\u0932\u093e","pricing":"\u0915\u093f\u0902\u092e\u0924 \u0928\u093f\u0930\u094d\u0927\u093e\u0930\u0923","current_price":"\u0935\u0930\u094d\u0924\u092e\u093e\u0928 \u0915\u093f\u0902\u092e\u0924","suggested_range":"\u0938\u0941\u091c\u093e\u0935\u093f\u0924 \u0938\u0940\u092e\u093e","performance":"\u092a\u094d\u0930\u0926\u0930\u094d\u0936\u0930\u094d\u0924\u093e","views":"\u0926\u0947\u0916\u0928\u0947","sold":"\u092c\u093f\u0915\u0947","revenue":"\u0906\u092e\u0926\u0928","price_suggestion":"\u0915\u093f\u0902\u092e\u0924 \u0938\u0941\u091c\u093e\u0935","close":"\u092c\u0902\u0926 \u0915\u0930\u0947\u0902","delete_product":"\u0909\u0924\u094d\u092a\u093e\u0926 \u0939\u091f\u093e\u090f\u0902","delete_confirm":"\u0915\u094d\u092f\u093e \u0906\u092a\u0915\u094b \u0935\u093e\u0915\u093e\u0908 \u0910\u0938\u093e \u0909\u0924\u094d\u092a\u093e\u0926 \u0939\u091f\u093e\u0928\u093e \u0939\u0948?","delete":"\u0939\u091f\u093e\u090f\u0902","order_details":"\u0911\u0930\u094d\u0921\u0930 \u0935\u093f\u0935\u0930\u0923","order_not_found":"\u0911\u0930\u094d\u0921\u0930 \u0928\u0939\u0940\u0902 \u092e\u093f\u0932\u093e","buyer_info":"\u0916\u0930\u0940\u0926\u093e\u0930 \u091c\u093e\u0928\u0915\u093e\u0930\u0940","order_items":"\u0911\u0930\u094d\u0921\u0930 \u0935\u0938\u094d\u0924\u0941\u090f\u0902","order_summary":"\u0911\u0930\u094d\u0921\u0930 \u0938\u093e\u0930\u093e\u0902\u0936","total_amount":"\u0915\u0941\u0932 \u0930\u093e\u0936\u093f","shipping_address":"\u0921\u093e\u0915\u0940\u0932\u093e \u092a\u0924\u093e","reject":"\u0905\u0938\u094d\u0935\u0940\u0915\u093e\u0930","accept":"\u0938\u094d\u0935\u0940\u0915\u093e\u0930","cancel_order":"\u0911\u0930\u094d\u0921\u0930 \u0930\u0926\u094d\u0926 \u0915\u0930\u0947\u0902","no":"\u0928\u0939\u0940\u0902","yes_cancel":"\u0939\u093e\u0902, \u0930\u0926\u094d\u0926 \u0915\u0930\u0947\u0902","order_accepted":"\u0911\u0930\u094d\u0921\u0930 \u0938\u094d\u0935\u0940\u0915\u093e\u0930 \u0939\u094b \u0917\u092f\u093e!","order_rejected":"\u0911\u0930\u094d\u0921\u0930 \u0905\u0938\u094d\u0935\u0940\u0915\u093e\u0930\u093f\u0924","order_cancelled":"\u0911\u0930\u094d\u0921\u0930 \u0930\u0926\u094d\u0926","cancel_confirm":"\u0915\u094d\u092f\u093e \u0906\u092a\u0915\u094b \u0935\u093e\u0915\u093e\u0908 \u092f\u0939 \u0911\u0930\u094d\u0921\u0930 \u0930\u0926\u094d\u0926 \u0915\u0930\u0928\u093e \u0939\u0948?","image_studio":"\u092b\u093c\u094b\u091f\u094b \u0938\u094d\u091f\u0942\u0921\u093f\u092f\u094b","save":"\u0938\u093e\u091a\u0947\u0902","processing_image":"\u092b\u093c\u094b\u091f\u094b \u092a\u094d\u0930\u0915\u094d\u0930\u093f\u092f\u093e \u0939\u094b \u0930\u0939\u0940 \u0939\u0948...","select_image":"\u0938\u0902\u092a\u093e\u0926\u093f\u0924 \u0915\u0930\u0928\u0947 \u0915\u0947 \u0932\u093f\u090f \u0915\u094b\u0908 \u092b\u093c\u094b\u091f\u094b \u091a\u0941\u0928\u0947\u0902","tools":"\u091f\u0942\u0932\u094d\u091a","enhance":"\u0938\u0941\u0927\u093e\u0930 \u0915\u0930\u0947\u0902","remove_bg":"\u092a\u0943\u0937\u094d\u092d\u0942\u092e\u0940 \u0939\u091f\u093e\u090f\u0902","crop":"\u0915\u093e\u091f\u0947\u0902","ecommerce":"\u0908-\u0915\u0949\u092e\u0930\u094d\u0938 \u0924\u0948\u092f\u093e\u0930","process_failed":"\u092b\u093c\u094b\u091f\u094b \u092a\u094d\u0930\u0915\u094d\u0930\u093f\u092f\u093e \u092e\u0947\u0902 \u0935\u093f\u092b\u093c\u0932","image_saved":"\u092b\u093c\u094b\u091f\u094b \u0938\u092b\u093c\u0932\u0924\u093e\u092a\u0942\u0930\u094d\u0935\u0915 \u0938\u093e\u091a\u093e!","nav_home":"\u0939\u094b\u092e","nav_products":"\u0909\u0924\u094d\u092a\u093e\u0926","nav_orders":"\u0911\u0930\u094d\u0921\u0930","nav_market":"\u092c\u093e\u091c\u093e\u0930","nav_profile":"\u092a\u094d\u0930\u094b\u092b\u093e\u0907\u0932",
}

# For remaining languages, we'll use English as fallback (en)
# The translate method already falls back to en when a key is missing

LANGUAGES = {
    'en': EN,
    'hi': HI,
}

# Now generate the Dart file
lines = []
lines.append("import 'package:flutter/material.dart';")
lines.append("import 'package:provider/provider.dart';")
lines.append("import '../providers/localization_provider.dart';")
lines.append("")
lines.append("extension LocExtension on BuildContext {")
lines.append("  String t(String key) {")
lines.append("    final lang = watch<LocalizationProvider>().currentLanguage;")
lines.append("    return LocalizationService.translate(key, lang);")
lines.append("  }")
lines.append("}")
lines.append("")
lines.append("class LocalizationService {")
lines.append("  static String translate(String key, String lang) {")
lines.append('    return _translations[lang]?[key] ?? _translations["en"]?[key] ?? key;')
lines.append("  }")
lines.append("")
lines.append("  static const Map<String, Map<String, String>> _translations = {")

for lang_code, lang_dict in LANGUAGES.items():
    lines.append(f"    '{lang_code}': {{")
    for key in KEYS:
        val = lang_dict.get(key, EN.get(key, key))
        val = val.replace("\\", "\\\\").replace("'", "\\'")
        lines.append(f"      '{key}': '{val}',")
    lines.append("    },")

lines.append("  };")
lines.append("}")
lines.append("")

content = '\n'.join(lines)
with open(OUT, 'w', encoding='utf-8') as f:
    f.write(content)
print(f"Written {len(content)} bytes to {OUT}")
print(f"Languages included: {list(LANGUAGES.keys())}")
print(f"Keys per language: {len(KEYS)}")
