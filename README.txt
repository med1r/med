MEDICAL ROBOTICS — SUPABASE CLOUD SETUP

1. Open Supabase Dashboard > SQL Editor > New query.
2. Open medical_robotics_supabase_setup.sql, copy all SQL, paste it into the editor, and click Run.
3. In Supabase Dashboard > Authentication > URL Configuration, add the website URL to Site URL and Redirect URLs. For local testing, you can add http://localhost:8000/** too.
4. Upload medical_robotics_media_portal_updated.html and the two image assets to your hosting (GitHub Pages is fine). Keep the image assets alongside index.html.
5. Open the site and enter the administrator email in “Cloud editor access”; click “Send sign-in link” and open the email link on the site.
6. In Supabase Dashboard > Authentication > Users, copy the UUID for that email.
7. In SQL Editor, run this statement with your real UUID:
   insert into public.admin_users (user_id) values ('YOUR-USER-UUID');
8. Refresh the website. The “Write an Article” button should now appear for the administrator. Published articles and photos are stored in Supabase and visible to all visitors.

SECURITY
- The sb_publishable key is intended for browser use. Never put a service_role or secret key in the HTML.
- Row Level Security policies in the SQL script make articles publicly readable but restrict publishing, editing and deletion to user IDs listed in admin_users.
- Keep your administrator email account secure.

NOTE
- Previously saved articles in the old browser-only localStorage are not automatically migrated. Re-publish them after cloud setup if you need them in the shared archive.
- This starter version supports publishing and public reading. Editing/deleting existing articles is not yet added to the editor.
