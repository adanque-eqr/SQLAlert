USE [master]
GO

/****** Object:  Database [SQLAlert]    Script Date: 7/6/2021 2:02:41 PM ******/
CREATE DATABASE [SQLAlert]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'SQLAlert', FILENAME = N'E:\SQL_DATA\SQLAlert.mdf' , SIZE = 102400KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'SQLAlert_log', FILENAME = N'D:\SQL_LOGS\SQLAlert_log.ldf' , SIZE = 73728KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SQLAlert].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [SQLAlert] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [SQLAlert] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [SQLAlert] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [SQLAlert] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [SQLAlert] SET ARITHABORT OFF 
GO

ALTER DATABASE [SQLAlert] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [SQLAlert] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [SQLAlert] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [SQLAlert] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [SQLAlert] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [SQLAlert] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [SQLAlert] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [SQLAlert] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [SQLAlert] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [SQLAlert] SET  DISABLE_BROKER 
GO

ALTER DATABASE [SQLAlert] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [SQLAlert] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [SQLAlert] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [SQLAlert] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [SQLAlert] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [SQLAlert] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [SQLAlert] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [SQLAlert] SET RECOVERY FULL 
GO

ALTER DATABASE [SQLAlert] SET  MULTI_USER 
GO

ALTER DATABASE [SQLAlert] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [SQLAlert] SET DB_CHAINING OFF 
GO

ALTER DATABASE [SQLAlert] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [SQLAlert] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [SQLAlert] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [SQLAlert] SET QUERY_STORE = OFF
GO

ALTER DATABASE [SQLAlert] SET  READ_WRITE 
GO
