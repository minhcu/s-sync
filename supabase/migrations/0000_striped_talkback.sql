DO $$ BEGIN
 CREATE TYPE "public"."permission_action" AS ENUM('create', 'read', 'update', 'delete', 'manage');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."permission_subject" AS ENUM('all', 'Post', 'Category', 'User');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."pricing_plan_interval" AS ENUM('day', 'week', 'month', 'year');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."pricing_type" AS ENUM('one_time', 'recurring');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."subscription_status" AS ENUM('trialing', 'active', 'canceled', 'incomplete', 'incomplete_expired', 'past_due', 'unpaid', 'paused');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 CREATE TYPE "public"."user_status" AS ENUM('active', 'deactivated', 'pending');
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "categories" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text,
	"slug" text NOT NULL,
	"description" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now(),
	"image_url" text,
	"user_id" uuid,
	"parent_id" uuid,
	CONSTRAINT "categories_slug_key" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "posts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"title" text,
	"slug" text NOT NULL,
	"description" text,
	"body" text,
	"category_id" uuid,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now(),
	"user_id" uuid DEFAULT gen_random_uuid(),
	CONSTRAINT "posts_slug_key" UNIQUE("slug")
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "projects" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"title" text,
	"description" text,
	"user_id" uuid DEFAULT gen_random_uuid(),
	"category_id" uuid DEFAULT gen_random_uuid()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_faq_categories" (
	"id" smallint PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY (sequence name "sys_faq_categories_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 32767 START WITH 1 CACHE 1),
	"title" text,
	"icon" text,
	"subtitle" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_faqs" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"answer" text,
	"category_id" smallint,
	"question" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_notifications" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"title" text,
	"message" text,
	"action" jsonb,
	"read_at" timestamp with time zone,
	"user_id" uuid DEFAULT gen_random_uuid()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_permissions" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"role_id" uuid,
	"action" "permission_action" DEFAULT 'read' NOT NULL,
	"subject" "permission_subject" NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_roles" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"name" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_shortcuts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"item" text,
	"user_id" uuid NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "sys_users" (
	"id" uuid PRIMARY KEY NOT NULL,
	"email" text,
	"phone" text,
	"full_name" text,
	"avatar_url" text,
	"created_at" timestamp with time zone DEFAULT now(),
	"deleted_at" timestamp with time zone,
	"role_id" uuid,
	"country" varchar,
	"language" varchar DEFAULT 'en',
	"organization" text,
	"postcode" varchar,
	"status" "user_status" DEFAULT 'pending',
	"address" text,
	"city" text
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user_devices" (
	"id" bigint PRIMARY KEY GENERATED BY DEFAULT AS IDENTITY (sequence name "user_devices_id_seq" INCREMENT BY 1 MINVALUE 1 MAXVALUE 922337203685477 START WITH 1 CACHE 1),
	"user_id" uuid DEFAULT gen_random_uuid(),
	"token_device" text,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user_payment_methods" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"number" text NOT NULL,
	"placeholder" text NOT NULL,
	"cvv" numeric NOT NULL,
	"expires_at" date NOT NULL,
	"user_id" uuid NOT NULL,
	"created_at" timestamp with time zone DEFAULT now() NOT NULL,
	"updated_at" timestamp with time zone DEFAULT now()
);
--> statement-breakpoint
CREATE TABLE IF NOT EXISTS "user_shortcuts" (
	"id" uuid PRIMARY KEY DEFAULT gen_random_uuid() NOT NULL,
	"route" text NOT NULL,
	"user_id" uuid DEFAULT gen_random_uuid()
);
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "categories" ADD CONSTRAINT "public_categories_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "categories" ADD CONSTRAINT "public_categories_parent_id_fkey" FOREIGN KEY ("parent_id") REFERENCES "public"."categories"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "posts" ADD CONSTRAINT "public_posts_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "posts" ADD CONSTRAINT "public_posts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "projects" ADD CONSTRAINT "public_projects_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "projects" ADD CONSTRAINT "public_projects_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."categories"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sys_faqs" ADD CONSTRAINT "public_sys_faqs_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."sys_faq_categories"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sys_notifications" ADD CONSTRAINT "public_sys_notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sys_permissions" ADD CONSTRAINT "public_sys_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."sys_roles"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sys_shortcuts" ADD CONSTRAINT "sys_shortcuts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "sys_users" ADD CONSTRAINT "public_sys_users_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."sys_roles"("id") ON DELETE no action ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_devices" ADD CONSTRAINT "public_user_devices_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE cascade ON UPDATE cascade;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_payment_methods" ADD CONSTRAINT "public_user_payment_methods_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;
--> statement-breakpoint
DO $$ BEGIN
 ALTER TABLE "user_shortcuts" ADD CONSTRAINT "public_user_shortcuts_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."sys_users"("id") ON DELETE cascade ON UPDATE no action;
EXCEPTION
 WHEN duplicate_object THEN null;
END $$;