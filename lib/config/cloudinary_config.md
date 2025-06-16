// Cloudinary Configuration
// 
// การตั้งค่า Cloudinary สำหรับ production:
// 
// 1. สมัครบัญชี Cloudinary (ฟรี): https://cloudinary.com/
// 2. หาข้อมูลต่อไปนี้ใน Dashboard:
//    - Cloud Name
//    - Upload Preset (สร้างใหม่ถ้ายังไม่มี)
// 
// 3. แก้ไขไฟล์ lib/services/cloudinary_service.dart:
//    - เปลี่ยน YOUR_CLOUD_NAME เป็น cloud name ของคุณ
//    - เปลี่ยน YOUR_UPLOAD_PRESET เป็น upload preset ของคุณ
//
// ตัวอย่าง:
// static const String _cloudName = 'my-app-cloud';
// static const String _uploadPreset = 'my_upload_preset';
//
// การสร้าง Upload Preset:
// 1. ไปที่ Settings > Upload
// 2. คลิก "Add upload preset"
// 3. ตั้งชื่อ (เช่น ml_default)
// 4. เลือก Signing Mode: "Unsigned"
// 5. บันทึก
//
// ประโยชน์ของ Cloudinary:
// - แก้ปัญหา CORS อัตโนมัติ
// - ปรับขนาดรูปแบบ dynamic
// - เปลี่ยนฟอร์แมตเป็น WebP สำหรับ web
// - CDN ทั่วโลก
// - Cache อัตโนมัติ

// สำหรับการทดสอบ สามารถใช้ค่าเหล่านี้ได้:
// Cloud Name: demo
// Upload Preset: ml_default
// 
// แต่สำหรับ production ควรสร้างบัญชีของตัวเอง
